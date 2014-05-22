package org.dspace.content.authority;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrInputDocument;
import org.elasticsearch.common.joda.time.DateTime;
import org.elasticsearch.common.joda.time.format.DateTimeFormatter;
import org.elasticsearch.common.joda.time.format.ISODateTimeFormat;

import java.text.SimpleDateFormat;
import java.util.*;

/**
 *
 * Representation of Authority record in Solr.
 *
 * @author Kevin Van de Velde (kevin at atmire dot com)
 * @author Mark Diggory (markd at atmire dot com)
 * @author Ben Bosman (ben at atmire dot com)
 * @author Lantian Gai (lantian at atmire dot com)
 */
public class AuthorityValue {


    /**
     * The id of the record in solr
     */
    private String id;

    /**
     * The metadata field that this authority value is for
     */
    private String field;

    /**
     * The text value of this authority
     */
    private String value;

    /**
     * When this authority record has been created
     */
    private Date creationDate;

    /**
     * If this authority has been removed
     */
    private boolean deleted;

    /**
     * represents the last time that DSpace got updated information from its external source
     */
    private Date lastModified;

    public AuthorityValue() {
    }

    public AuthorityValue(SolrDocument document) {
        setValues(document);
    }

    public String getId() {
        return id;
    }

    public String getField() {
        return field;
    }

    public String getValue() {
        return value;
    }

    public void setId(String id) {
        this.id = id;
    }

    public void setField(String field) {
        this.field = field;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public Date getCreationDate() {
        return creationDate;
    }

    public void setCreationDate(Date creationDate) {
        this.creationDate = creationDate;
    }

    public void setCreationDate(String creationDate) {
        this.creationDate = stringToDate(creationDate);
    }

    public Date getLastModified() {
        return lastModified;
    }

    public void setLastModified(String lastModified) {
        this.lastModified = stringToDate(lastModified);
    }

    public void setLastModified(Date lastModified) {
        this.lastModified = lastModified;
    }

    public boolean isDeleted() {
        return deleted;
    }

    public void setDeleted(boolean deleted) {
        this.deleted = deleted;
    }

    protected void updateLastModifiedDate() {
        this.lastModified = new Date();
    }

    public void update() {
        updateLastModifiedDate();
    }

    public void delete() {
        setDeleted(true);
        updateLastModifiedDate();
    }

    /**
     * Generate a solr record from this instance
     */
    public SolrInputDocument getSolrInputDocument() {

        SolrInputDocument doc = new SolrInputDocument();
        doc.addField("id", getId());
        doc.addField("field", getField());
        doc.addField("value", getValue());
        doc.addField("display-value", getValue());
        doc.addField("full-text", getValue());
        doc.addField("source", "LOCAL");
        doc.addField("deleted", isDeleted());
        doc.addField("creation_date", dateToString(getCreationDate()));
        doc.addField("last_modified_date", dateToString(getLastModified()));
        doc.addField("authority_type", getAuthorityType());

        return doc;
    }

    /**
     * Initialize this instance based on a solr record
     */
    public void setValues(SolrDocument document) {
        this.id = String.valueOf(document.getFieldValue("id"));
        this.field = String.valueOf(document.getFieldValue("field"));
        this.value = String.valueOf(document.getFieldValue("value"));
        if(document.getFieldValue("deleted")!=null)
        this.deleted = (Boolean) document.getFieldValue("deleted");
        this.creationDate = (Date) document.getFieldValue("creation_date");
        this.lastModified = (Date) document.getFieldValue("last_modified_date");
    }

    /**
     * Information that can be used the choice ui
     */
    public Map<String, String> choiceSelectMap() {
        return new HashMap<String, String>();
    }


    public List<DateTimeFormatter> getDateFormatters() {
        List<DateTimeFormatter> list = new ArrayList<DateTimeFormatter>();
        list.add(ISODateTimeFormat.dateTime());
        list.add(ISODateTimeFormat.dateTimeNoMillis());
        return list;
    }

    public String dateToString(Date date) {
        String string = null;
        if (date != null) {
            SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
            string = format.format(date);
        }
        return string;
    }

    public Date stringToDate(String date) {
        Date result = null;
        if (StringUtils.isNotBlank(date)) {
            List<DateTimeFormatter> dateFormatters = getDateFormatters();
            boolean converted = false;
            int formatter = 0;
            while(!converted) {
                try {
                    DateTimeFormatter dateTimeFormatter = dateFormatters.get(formatter);
                    DateTime dateTime = dateTimeFormatter.parseDateTime(date);
                    result = dateTime.toDate();
                    converted = true;
                } catch (IllegalArgumentException e) {
                    formatter++;
                    if (formatter > dateFormatters.size()) {
                        converted = true;
                    }
                    log.error("Could not find a valid date format for: \""+date+"\"", e);
                }
            }
        }
        return result;
    }

    /**
     * log4j logger
     */
    private static Logger log = Logger.getLogger(AuthorityValue.class);

    @Override
    public String toString() {
        return "AuthorityValue{" +
                "id='" + id + '\'' +
                ", field='" + field + '\'' +
                ", value='" + value + '\'' +
                ", creationDate=" + creationDate +
                ", deleted=" + deleted +
                ", lastModified=" + lastModified +
                '}';
    }

    public String getAuthorityType() {
        return "internal";
    }


    public static AuthorityValue fromSolr(SolrDocument solrDocument) {
        AuthorityValue value = new AuthorityValue();
        value.setValues(solrDocument);
        return value;
    }



    /**
     * The regular equals() only checks if both AuthorityValues describe the same authority.
     * This method checks if the AuthorityValues have different information
     * E.g. it is used to decide when lastModified should be updated.
     */
    public boolean hasTheSameInformationAs(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        AuthorityValue that = (AuthorityValue) o;

        if (deleted != that.deleted) {
            return false;
        }
        if (field != null ? !field.equals(that.field) : that.field != null) {
            return false;
        }
        if (id != null ? !id.equals(that.id) : that.id != null) {
            return false;
        }
        if (value != null ? !value.equals(that.value) : that.value != null) {
            return false;
        }

        return true;
    }
}
