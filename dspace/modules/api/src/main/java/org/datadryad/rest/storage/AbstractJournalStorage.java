/*
 */
package org.datadryad.rest.storage;

import java.util.Arrays;
import java.util.List;

import org.datadryad.rest.models.Journal;

/**
 *
 * @author Dan Leehr <dan.leehr@nescent.org>
 */
public abstract class AbstractJournalStorage extends AbstractStorage<Journal> {
    @Override
    public final void checkCollectionPath(StoragePath path) throws StorageException {
        final List<String> expectedKeyPath = Arrays.asList(); // Collection is root
        checkPath(path, expectedKeyPath);

    }

    @Override
    public final void checkObjectPath(StoragePath path) throws StorageException {
        final List<String> expectedKeyPath = Arrays.asList(StoragePath.JOURNAL_PATH);
        checkPath(path, expectedKeyPath);
    }
}
