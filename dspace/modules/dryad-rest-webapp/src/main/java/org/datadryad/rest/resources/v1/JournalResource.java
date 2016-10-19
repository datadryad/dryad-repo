/*
 */
package org.datadryad.rest.resources.v1;

import org.datadryad.rest.models.Journal;
import org.datadryad.rest.responses.ErrorsResponse;
import org.datadryad.rest.responses.ResponseFactory;
import org.datadryad.rest.storage.AbstractJournalStorage;
import org.datadryad.rest.storage.StorageException;
import org.datadryad.rest.storage.StoragePath;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.*;
import javax.ws.rs.core.*;
import javax.ws.rs.core.Response.Status;
import java.util.List;

/**
 *
 * @author Dan Leehr <dan.leehr@nescent.org>
 */

@Path("journals")
public class JournalResource {
    @Context
    AbstractJournalStorage journalStorage;
    @Context UriInfo uriInfo;
    @Context HttpServletRequest request;

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Response getJournals() {
        try {
            List<Journal> allJournalList = journalStorage.getAll(new StoragePath());
            // Returning a list requires POJO turned on
            return Response.ok(allJournalList).build();
        } catch (StorageException ex) {
            ErrorsResponse error = ResponseFactory.makeError(ex.getMessage(), "Unable to list journals", uriInfo, Status.INTERNAL_SERVER_ERROR.getStatusCode());
            return error.toResponse().build();
        }
    }

    @Path("/{journalRef}")
    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Response getJournal(@PathParam(StoragePath.JOURNAL_PATH) String issn) {
        StoragePath path = StoragePath.createJournalPath(issn);
        try {
            Journal journal = journalStorage.findByPath(path);
            if (journal == null) {
                ErrorsResponse error = ResponseFactory.makeError("Journal with code " + issn + " does not exist", "Journal not found", uriInfo, Status.NOT_FOUND.getStatusCode());
                return Response.status(Status.NOT_FOUND).entity(error).build();
            } else {
                return Response.ok(journal).build();
            }
        } catch (StorageException ex) {
            ErrorsResponse error = ResponseFactory.makeError(ex.getMessage(), "Unable to get journal", uriInfo, Status.INTERNAL_SERVER_ERROR.getStatusCode());
            return error.toResponse().build();
        }
    }
}

