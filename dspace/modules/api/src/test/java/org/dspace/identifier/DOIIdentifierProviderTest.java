package org.dspace.identifier;

import org.dspace.identifier.DOIIdentifierProvider;
import org.junit.Test;
import junit.framework.TestCase;
import static org.junit.Assert.*;

import java.util.regex.*;


/**
 *
 * @author Daisie Huang <daisieh@datadryad.org>
 */
public class DOIIdentifierProviderTest extends DOIIdentifierProvider{

    public DOIIdentifierProviderTest() {
    }

    @Test
    public void testDOIs() {
        DOIIdentifierProvider dip = new DOIIdentifierProvider();
        System.out.println("Testing validity of DOIs ");
        String doi = "";
        String canonicalID = "";
        if (configurationService == null) {
            System.out.println("no configuration service");
            myDoiPrefix = "10.5061";
            myDoiTestPrefix = "10.5072";
            myLocalPartSuffix = "dryad.";
            myLocalPartTestSuffix = "FK2.5061.dryad.";
        }
        doi = "doi:10.5061/dryad.64274";
        canonicalID = dip.getCanonicalDataPackage(doi);
        System.out.println("DOI "+doi+ " has a canonical ID of "+ canonicalID);
        assertTrue("Regular DOI " + doi + " canonical ID incorrect: " + canonicalID, canonicalID.equals("doi:10.5061/dryad.64274"));

        doi = "doi:10.5072/FK2.5061.dryad.dn470";
        canonicalID = dip.getCanonicalDataPackage(doi);
        System.out.println("DOI "+doi+ " has a canonical ID of "+ canonicalID);
        assertTrue("Test DOI " + doi + " canonical ID incorrect: " + canonicalID, canonicalID.equals("doi:10.5072/FK2.5061.dryad.dn470"));

        doi = "info:doi/10.5061/dryad.64274/1";
        canonicalID = dip.getCanonicalDataPackage(doi);
        System.out.println("DOI "+doi+ " has a canonical ID of "+ canonicalID);
        assertTrue("File DOI " + doi + " canonical ID incorrect: " + canonicalID, canonicalID.equals("info:doi/10.5061/dryad.64274"));

        doi = "doi:10.5061/dryad.64274.2";
        canonicalID = dip.getCanonicalDataPackage(doi);
        System.out.println("DOI "+doi+ " has a canonical ID of "+ canonicalID);
        assertTrue("Version DOI " + doi + " canonical ID incorrect: " + canonicalID, canonicalID.equals("doi:10.5061/dryad.64274"));

        doi = "doi:10.5061/dryad.64274.2/2.2";
        canonicalID = dip.getCanonicalDataPackage(doi);
        System.out.println("DOI "+doi+ " has a canonical ID of "+ canonicalID);
        assertTrue("Versioned file DOI " + doi + " canonical ID incorrect: " + canonicalID, canonicalID.equals("doi:10.5061/dryad.64274"));

//        canonicalID = dip.getCanonicalDataFile(doi);
//        System.out.println("DOI "+doi+ " has a canonical ID of "+ canonicalID);
//        assertTrue("Versioned file DOI " + doi + " canonical ID incorrect: " + canonicalID, canonicalID.equals("doi:10.5061/dryad.64274/2"));
    }

}