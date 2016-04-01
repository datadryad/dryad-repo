/*
  This is the ingester for BagIt for packages that are in Dryad's
  particular format.  A package here (e.g. from a SWORD deposit) is a
  .zip file.  Dryad's format is as follows: 

  The data/ directory contains 
  (1) dryadpkg.xml, metadata for the Dryad package in DMAP form
  (2) dryadpub.xml, metadata for the publication in DMAP form
  (3) one directory per data file, each one containing the file and a
      .xml file containing data file metadata

  In addition to processing the DMAP (Dryad metadata application
  format) metadata, this code consults Crossref to fill in
  bibliographic information.

  The data package is left in a workspace; unlike the METS ingester,
  it is not submitted to a workflow.

  This class uses instance variables that are specific to one ingest.
  I don't know whether the instance gets reused for multiple ingests;
  if it is then we may have contention, and the code should be changed
  to created separate instances (of some new class), one per ingest.

*/

package org.dspace.content.packager;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Collections;
import java.util.Enumeration;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.sql.SQLException;
import java.util.Date;
import org.jdom.input.SAXBuilder;
import org.jdom.JDOMException;
import org.jdom.Document;

import org.apache.log4j.Logger;

import org.dspace.core.PluginManager;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.crosswalk.CrosswalkException;
import org.dspace.content.crosswalk.IngestionCrosswalk;
import org.dspace.content.crosswalk.MetadataValidationException;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.DCValue;
import org.dspace.content.packager.PackageException;
import org.dspace.content.packager.PackageParameters;
import org.dspace.content.packager.AbstractPackageIngester;
import org.dspace.content.packager.PackageValidationException;
import org.dspace.submit.step.SelectPublicationStep;

import org.datadryad.api.DryadDataPackage;
import org.datadryad.api.DryadDataFile;

/*
  Modeled after:
  dspace-api/src/main/java/org/dspace/content/packager/AbstractMETSIngester.java:
  dspace-api/src/main/java/org/dspace/content/packager/DSpaceMETSIngester.java
  dspace/modules/bagit/dspace-bagit-api/src/main/java/org/dspace/content/packager/BagItDisseminator.java
  dspace/modules/bagit/dspace-bagit-api/src/main/java/org/dspace/content/packager/BagItBuilder.java
  See also:
  dspace-api/src/main/java/org/dspace/content/packager/METSManifest.java

  How do we get here?  See
  plugin.named.org.dspace.content.packager.PackageIngester in
  dspace.cfg.
  org.dspace.sword.DryadBagItIngester = http://purl.org/net/sword-types/bagit \

  To turn on logging, edit dspace/config/log4j.properties
*/

public class DryadBagItIngester
        extends AbstractPackageIngester
{
    /** Log4j logger */
    private static final Logger mylog = Logger.getLogger(DryadBagItIngester.class);

    List<ZipEntry[]> entries;
    ZipEntry dryadpkg = null, dryadpub = null;

    @Override
    public DSpaceObject ingest(Context context, DSpaceObject parent, File pkgFile,
                        PackageParameters params, String license)
        throws PackageException, CrosswalkException,
               AuthorizeException, SQLException, IOException
    {
	mylog.info("Parsing package, file=" + pkgFile.getName());
        ZipFile zip = new ZipFile(pkgFile);
        parseZip(zip);

        mylog.info(String.format("pkg: %s %s", dryadpkg.getName(), dryadpkg.getSize()));
	mylog.info(String.format("pub: %s %s", dryadpub.getName(), dryadpub.getSize()));

        DryadDataPackage dp = DryadDataPackage.createInWorkspace(context);

	// Do data package crosswalk:

	// Get package metadata as XML document
        SAXBuilder builder = new SAXBuilder(false);
        builder.setIgnoringElementContentWhitespace(true);
        Document pkgDocument;
        try {
            pkgDocument = builder.build(zip.getInputStream(dryadpkg));
            mylog.info(String.format("Got document for %s", dryadpkg.getName()));
        }
        catch (JDOMException je) {
            throw new MetadataValidationException("Error validating DMAP in "
                    + dryadpkg.getName(),  je);
        }

        // Get crosswalk plugin
        String xwalkName = "DRYAD-V3-1-INGEST";
        IngestionCrosswalk xwalk = (IngestionCrosswalk) PluginManager
				.getNamedPlugin(IngestionCrosswalk.class, xwalkName);
        if (xwalk == null)
            // This isn't really the right exception type
            throw new MetadataValidationException("Cannot find Dryad ingest crosswalk " + xwalkName);
        else {
            mylog.info("Got crosswalk for " + xwalkName);
            xwalk.ingest(context, dp.getItem(), pkgDocument.getRootElement());
            mylog.info("Ingested metadata");
        }

	// TBD: do publication crosswalk on dryadpub (!? maybe no useful information there)

        // Fill in article metadata by consult Crossref
        DCValue[] values = dp.getItem().getMetadata("dc", "relation", "isreferencedby", Item.ANY);
        if (values != null && values.length > 0) {
            mylog.info("Processing DOI");
            SelectPublicationStep.processDOI(context, dp.getItem(), values[0].value);
        } else
            mylog.info("No DOI to process");

        // {metadata, content}
        for (ZipEntry[] entryPair : entries) {
	    ZipEntry metadata = entryPair[0];
	    ZipEntry data = entryPair[1];
            mylog.info(String.format("Processing: %s %s", metadata.getName(), data.getName()));
            DryadDataFile df = DryadDataFile.createInWorkspace(context, dp);
            df.addBitstream(zip.getInputStream(data));
            // Do data file crosswalk
        }
        zip.close();
        return dp.getItem();
    }

    // Computes:
    //   entries   -- a list of {metadata, datafile} entry pairs
    //   dryadpub   -- metadata for publication
    //   dryadpkg   -- metadata for data package

    void parseZip(ZipFile zip) throws IOException, PackageValidationException
    {
        List<ZipEntry> allEntries = Collections.list((Enumeration<ZipEntry>)zip.entries());
        int pos = -1;
        Map<String, String> datafiles = new HashMap<String, String>();
        Map<String, String> metafiles = new HashMap<String, String>();
        for (ZipEntry entry : allEntries) {
            String wholename = entry.getName();
            if (wholename.endsWith("/") || wholename.startsWith("__MACOSX"))
                continue;
            int where = wholename.indexOf("data/");
            if (where >= 0) {
                where += 5;
                if (pos >= 0) {
                    if (where != pos)
                        throw new PackageValidationException("Multiple data/ directories");
                } else
                    pos = where;
                String name = wholename.substring(pos);
                if (name.equals("dryadpub.xml"))
                    dryadpub = entry;
                else if (name.equals("dryadpkg.xml"))
                    dryadpkg = entry;
                else {
                    // E.g. dryadfile-1/ApineCYTB.nexus
                    //  and dryadfile-1/dryadfile-1.xml
                    int slash = name.indexOf('/');
                    if (slash >= 0) {
                        String before = name.substring(0, slash);
                        String after = name.substring(slash+1);
                        if (after.startsWith("dryadfile-") && 
                              after.endsWith(".xml") &&
                              metafiles.get(before) == null)
                            metafiles.put(before, wholename);
                        else if (datafiles.get(before) == null)
                            datafiles.put(before, wholename);
                        else
                            throw new PackageValidationException
                                ("fifth wheel: %s\t%s".format(wholename, entry.getSize()));
                    } else
                        throw new PackageValidationException
                            ("unknown: %s\t%s".format(wholename, entry.getSize()));
                }

                if (false) {
                    InputStreamReader r = new InputStreamReader(zip.getInputStream(entry));
                    char[] buf = new char[1000];
                    int howmany = r.read(buf, 0, 1000);
                    mylog.info(new String(buf, 0, howmany));
                }
            }
        }
        if (dryadpub == null || dryadpkg == null)
            throw new PackageValidationException("missing pub or pkg");
        entries = new ArrayList<ZipEntry[]>();
        for (String before : datafiles.keySet()) {
            String m = metafiles.get(before);
            String d = datafiles.get(before);
            if (m != null && d != null) {
                ZipEntry me = zip.getEntry(metafiles.get(before));
                ZipEntry de = zip.getEntry(datafiles.get(before));
                if (me != null && de != null)
                    entries.add(new ZipEntry[]{me, de});
                else
                    // shouldn't happen
                    throw new PackageValidationException
                        ("missing entry: me=%s de=%s".format(m, d));
            } else
                // could happen if input is corrupt
                throw new PackageValidationException
                    ("missing file: m=%s d=%s".format(m, d));
        }
    }

    @Override
    public DSpaceObject replace(Context context, DSpaceObject dso,
                         File pkgFile, PackageParameters params)
        throws PackageException, UnsupportedOperationException,
               CrosswalkException, AuthorizeException,
               SQLException, IOException
    {
        return null;
    }

    @Override
    public String getParameterHelp() {
        return null;
    }



}
