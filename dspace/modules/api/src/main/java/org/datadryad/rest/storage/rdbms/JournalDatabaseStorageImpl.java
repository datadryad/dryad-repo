/*
 */
package org.datadryad.rest.storage.rdbms;

import java.io.File;
import java.lang.Exception;
import java.lang.Integer;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.apache.log4j.Logger;
import org.datadryad.api.DryadJournalConcept;
import org.datadryad.rest.models.Journal;
import org.datadryad.rest.storage.AbstractJournalStorage;
import org.datadryad.rest.storage.StorageException;
import org.datadryad.rest.storage.StoragePath;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import org.dspace.storage.rdbms.DatabaseManager;
import org.dspace.storage.rdbms.TableRow;
import org.dspace.JournalUtils;

import static org.datadryad.rest.storage.rdbms.JournalConceptDatabaseStorageImpl.COLUMN_CODE;

/**
 *
 * @author Dan Leehr <dan.leehr@nescent.org>
 */
public class JournalDatabaseStorageImpl extends AbstractJournalStorage {
    private static Logger log = Logger.getLogger(JournalDatabaseStorageImpl.class);

    static final String JOURNAL_TABLE = "journal";

    static final String COLUMN_ID = "concept_id";
    static final String COLUMN_NAME = "name";
    static final String COLUMN_ISSN = "issn";
    static final List<String> JOURNAL_COLUMNS = Arrays.asList(
            COLUMN_ID,
            COLUMN_NAME,
            COLUMN_ISSN
    );

    public JournalDatabaseStorageImpl(String configFileName) {
        setConfigFile(configFileName);
    }

    public JournalDatabaseStorageImpl() {
        // For use when ConfigurationManager is already configured
    }

    public final void setConfigFile(String configFileName) {
	File configFile = new File(configFileName);

	if (configFile != null) {
	    if (configFile.exists() && configFile.canRead() && configFile.isFile()) {
		ConfigurationManager.loadConfig(configFile.getAbsolutePath());
            }
        }
    }
    
    private static Context getContext() {
        Context context = null;
        try {
            context = new Context();
        } catch (SQLException ex) {
            log.error("Unable to instantiate DSpace context", ex);
        }
        return context;
    }

    private static void completeContext(Context context) throws SQLException {
        try {
            context.complete();
        } catch (SQLException ex) {
            // Abort the context to force a new connection
            abortContext(context);
            throw ex;
        }
    }

    private static void abortContext(Context context) {
        if (context != null) {
            context.abort();
        }
    }

    public static Journal getJournalByISSN(Context context, String issn) throws SQLException {
        String query = "SELECT * FROM " + JOURNAL_TABLE + " WHERE UPPER(" + COLUMN_ISSN + ") = UPPER(?)";
        TableRow row = DatabaseManager.querySingleTable(context, JOURNAL_TABLE, query, issn);
        Journal journal = null;
        if (row != null) {
            journal = new Journal();
            journal.conceptID = row.getIntColumn(COLUMN_ID);
            journal.issn = row.getStringColumn(COLUMN_ISSN);
            journal.fullName = row.getStringColumn(COLUMN_NAME);
        }
        return journal;
    }

    @Override
    public Boolean objectExists(StoragePath path, Journal journal) {
        String name = journal.fullName;
        Boolean result = false;
        if (JournalUtils.getJournalConceptByJournalName(name) != null) {
            result = true;
        }
        return result;
    }

    protected void addAll(StoragePath path, List<Journal> journalConcepts) throws StorageException {
        // passing in a limit of null to addResults should return all records
        addResults(path, journalConcepts, null, null);
    }

    @Override
    protected void addResults(StoragePath path, List<Journal> journals, String searchParam, Integer limit) throws StorageException {
        Context context = null;
        try {
            ArrayList<DryadJournalConcept> allJournals = new ArrayList<DryadJournalConcept>();
            context = getContext();
            DryadJournalConcept[] dryadJournals = JournalUtils.getAllJournalConcepts();
            allJournals.addAll(Arrays.asList(dryadJournals));
            completeContext(context);
            for (DryadJournalConcept journalConcept : allJournals) {
                Journal journal = new Journal(journalConcept);
                if (journal.isValid()) {
                    if (searchParam != null) {
                        if (journalConcept.getISSN().equalsIgnoreCase(searchParam)) {
                            journals.add(journal);
                        }
                    } else {
                        journals.add(journal);
                    }
                }
            }
        } catch (SQLException ex) {
            abortContext(context);
            throw new StorageException("Exception reading journals", ex);
        }
    }

    @Override
    protected void createObject(StoragePath path, Journal journalConcept) throws StorageException {
        throw new StorageException("Can't create a journal");
    }

    @Override
    protected Journal readObject(StoragePath path) throws StorageException {
        Journal journalConcept = null;
        Context context = null;
        try {
            context = getContext();
            journalConcept = getJournalByISSN(context, path.getJournalRef());
            completeContext(context);
        } catch (Exception e) {
            abortContext(context);
            throw new StorageException("Exception reading journal: " + e.getMessage());
        }
        return journalConcept;
    }

    @Override
    protected void deleteObject(StoragePath path) throws StorageException {
        throw new StorageException("Can't delete an journal");
    }

    @Override
    protected void updateObject(StoragePath path, Journal journalConcept) throws StorageException {
        throw new StorageException("Can't update a journal");
    }
}
