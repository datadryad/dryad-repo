package org.dspace.content.packager;

import java.io.File;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import org.apache.log4j.Logger;
import org.datadryad.test.ContextUnitTest;
import org.dspace.content.DSpaceObject;
import org.dspace.content.DCValue;
import org.dspace.content.Item;
import org.dspace.core.ConfigurationManager;

import org.junit.Test;
import static org.junit.Assert.*;
import org.junit.Before;

/**
 *
 * @author Jonathan Rees <rees@mumble.net>
 */
public class DryadBagItIngesterTest extends ContextUnitTest {
    private static Logger log = Logger.getLogger(DryadBagItIngesterTest.class);
    private File file = null;

    @Before
    public void setUp() {
        super.setUp();
        try {
            file = new File(DryadBagItIngesterTest.class.getClassLoader().getResource("2850-bagit.zip").toURI());
        } catch (Exception ex) {
            fail("Exception setting up files for total size test " + ex);
        }
    }

    @Test
    public void testParseZip() throws Exception {
        ZipFile zip = new ZipFile(file);
        DryadBagItIngester dbi = new DryadBagItIngester();
        dbi.parseZip(zip);
        assertTrue("got package metadata", dbi.dryadpkg != null);
        assertTrue("got publication metadata", dbi.dryadpub != null);
        assertTrue("at least one data file", dbi.entries.size() > 0);
    }

    @Test
    public void testIngest() throws Exception {
        assertTrue("stylesheet defined",
                   ConfigurationManager.getProperty("crosswalk.submission.DRYAD-V3-1-INGEST.stylesheet")
                   != null);
        DryadBagItIngester dbi = new DryadBagItIngester();
        DSpaceObject dso = dbi.ingest(context, null, file, null, null);
        assertTrue("ingested an Item", dso instanceof Item);
        Item dp = (Item)dso;
        // TBD: check the partof structure
        DCValue[] values = dp.getMetadata("dc", "relation", "isreferencedby", Item.ANY);
        assertTrue("nonnull isreferencedby", values != null);
        assertTrue("at least one isreferencedby", values.length > 0);
        // Does Crossref fetch work?
        DCValue[] values2 = dp.getMetadata("dc", "title", Item.ANY, Item.ANY);
        assertTrue("nonnull title", values2 != null);
        assertTrue("at least one title", values2.length > 0);
    }
}
