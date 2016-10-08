/*
 */
package org.datadryad.rest.models;

import org.datadryad.api.DryadJournalConcept;

import javax.xml.bind.annotation.XmlRootElement;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.lang.Object;
import java.lang.Override;

/**
 *
 * @author Dan Leehr <dan.leehr@nescent.org>
 */
@XmlRootElement
@JsonIgnoreProperties(ignoreUnknown = true)
public class Journal {
    public Integer conceptID;
    public String journalID = "";
    public String fullName = "";
    public String issn = "";

    public Journal() {
    }

    public Journal(DryadJournalConcept dryadJournalConcept) {
        conceptID = new Integer(dryadJournalConcept.getConceptID());
        journalID = dryadJournalConcept.getJournalID();
        fullName = dryadJournalConcept.getFullName();
        issn = dryadJournalConcept.getISSN();
    }

    public Boolean isValid() {
        return (journalID != null && journalID.length() > 0);
    }

    @Override
    public boolean equals(Object o) {
        if (o.getClass().equals(this.getClass())) {
            Journal journal = (Journal) o;
            if (this.journalID.equals(journal.journalID) && this.fullName.equals(journal.fullName) && this.issn.equals(journal.issn)) {
                return true;
            }
        }
        return false;
    }
}
