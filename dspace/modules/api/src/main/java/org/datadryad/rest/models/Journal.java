/*
 */
package org.datadryad.rest.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
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
    @JsonIgnore
    public Integer conceptID;
    public String fullName = "";
    public String issn = "";

    public Journal() {
    }

    public Journal(DryadJournalConcept dryadJournalConcept) {
        conceptID = new Integer(dryadJournalConcept.getConceptID());
        fullName = dryadJournalConcept.getFullName();
        issn = dryadJournalConcept.getISSN();
    }

    @JsonIgnore
    public Boolean isValid() {
        return (fullName != null && fullName.length() > 0 && issn != null && issn.length() > 0);
    }

    @Override
    public boolean equals(Object o) {
        if (o.getClass().equals(this.getClass())) {
            Journal journal = (Journal) o;
            if (this.issn.equals(journal.issn) && this.fullName.equals(journal.fullName)) {
                return true;
            }
        }
        return false;
    }
}
