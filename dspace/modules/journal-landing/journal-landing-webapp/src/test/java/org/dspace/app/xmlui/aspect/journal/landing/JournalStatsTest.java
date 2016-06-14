package org.dspace.app.xmlui.aspect.journal.landing;

import org.datadryad.api.DryadJournalConcept;
import org.dspace.app.xmlui.wing.element.Body;
import org.dspace.content.authority.Concept;
import org.jdom2.Document;
import org.jdom2.filter.Filters;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;
import org.junit.Before;
import org.junit.Test;

import static org.dspace.JournalUtils.*;
import static org.junit.Assert.assertTrue;

/**
 * @author Nathan Day
 */
public class JournalStatsTest extends JournalLandingBaseTest
{

    private JournalStats journalStats;
    String journalIssn = "1111-1111";
    String journalName = "Evolution";
    String journalAbbr = "Evol";
    Concept c;
    DryadJournalConcept djc;

    @Before
    public void setUp() {
        super.setUp();
        journalStats = new JournalStats();
        try {
            c = Concept.findByConceptMetadata(context, journalIssn, "journal", "issn").get(0);
            djc = getJournalConceptByISSN(journalIssn);
            if (djc == null) {
                djc = new DryadJournalConcept(this.context, c);
                djc.setFullName(journalName);
                djc.setISSN(journalIssn);
                addDryadJournalConcept(context, djc);
            }
            parameters.setParameter(Const.PARAM_JOURNAL_ISSN, journalIssn);
            parameters.setParameter(Const.PARAM_JOURNAL_NAME, journalName);
            parameters.setParameter(Const.PARAM_JOURNAL_ABBR, journalAbbr);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Test
    public void testSetup() throws Exception {
        journalStats.setup(resolver, objectModel, src, parameters);
    }

}