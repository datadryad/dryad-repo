package org.dspace.content.authority;

import org.dspace.core.Context;

import java.io.IOException;
import java.sql.SQLException;

/**
 * Indexing API for Solr based Authority Control Service.
 *
 * @author Lantian Gai, Mark Diggory, Kevin Van de Velde
 */
public interface AuthorityIndexingService {



    /**
     * Index a specific Concept
     * @param context
     * @param concept
     * @param force will force reindexing even if concept is uptodate
     * @throws java.sql.SQLException
     */
    public void indexContent(Context context, Concept concept, boolean force) throws SQLException;

    /**
     * Unindex Concept
     * @param context
     * @param identifier Identifier of Concept that should be unindexed
     * @param commit
     * @throws java.sql.SQLException
     * @throws java.io.IOException
     */
    public void unIndexContent(Context context, String identifier, boolean commit) throws SQLException, IOException;

    /**
     * Unindex Concept
     * @param context
     * @param concept
     * @throws java.sql.SQLException
     * @throws java.io.IOException
     */
    public void unIndexContent(Context context, Concept concept) throws SQLException, IOException;

    /**
     * Remove all Concepts from authority index
     * @throws Exception
     */
    public void cleanIndex() throws Exception;

    /**
     * Commit authority index changes if they have not already
     */
    public void commit();

    /**
     * Update entire Index, using force will initialize each concept from database.
     * Run cleanIndex first if you want to completely rebuild index.
     * @param context
     * @param force
     */
    void updateIndex(Context context, boolean force);


    /**
     * Optimize Index
     */
    void optimize();
}
