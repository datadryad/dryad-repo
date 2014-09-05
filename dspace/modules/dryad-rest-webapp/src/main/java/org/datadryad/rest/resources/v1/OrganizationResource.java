/*
 */
package org.datadryad.rest.resources.v1;

import java.net.URI;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;
import javax.ws.rs.core.UriBuilder;
import javax.ws.rs.core.UriInfo;
import org.datadryad.rest.models.Organization;
import org.datadryad.rest.storage.AbstractOrganizationStorage;
import org.datadryad.rest.storage.StorageException;
import org.datadryad.rest.storage.StoragePath;

/**
 *
 * @author Dan Leehr <dan.leehr@nescent.org>
 */

@Path("organizations")
public class OrganizationResource {
    @Context AbstractOrganizationStorage organizationStorage;
    @Context UriInfo uriInfo;
    @Context HttpServletRequest request;


    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Response getOrganizations() {
        try {
            // Returning a list requires POJO turned on
            return Response.ok(organizationStorage.getAll(new StoragePath())).build();
        } catch (StorageException ex) {
            return Response.serverError().entity(ex.getMessage()).build();
        }
    }

    @Path("/{organizationCode}")
    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Response getOrganization(@PathParam(Organization.ORGANIZATION_CODE) String organizationCode) {
        StoragePath path = new StoragePath();
        path.addPathElement(Organization.ORGANIZATION_CODE, organizationCode);
        try {
            Organization organization = organizationStorage.findByPath(path);
            if(organization == null) {
                return Response.status(Status.NOT_FOUND).build();
            } else {
                return Response.ok(organization).build();
            }
        } catch (StorageException ex) {
            // what to do here?
            return Response.serverError().entity(ex.getMessage()).build();
        }
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    public Response createOrganization(Organization organization) {
        System.err.println("Organization received with name: " + organization.organizationName + ", Code: " + organization.organizationCode);
        // Check required fields
        if(organization.isValid()) {
            try {
                organizationStorage.create(new StoragePath(), organization);
            } catch (StorageException ex) {
                return Response.status(Response.Status.BAD_REQUEST).entity(ex.getMessage()).build();
            }
            UriBuilder ub = uriInfo.getAbsolutePathBuilder();
            URI uri = ub.path(organization.organizationCode).build();
            return Response.created(uri).build();
        } else {
            return Response.status(Response.Status.BAD_REQUEST).entity("Organization Code not found").build();
        }
    }

    @Path("/{organizationCode}")
    @PUT
    @Consumes(MediaType.APPLICATION_JSON)
    public Response updateOrganization(@PathParam(Organization.ORGANIZATION_CODE) String organizationCode, Organization organization) {
        System.err.println("Organization received with name: " + organization.organizationName + ", Code: " + organization.organizationCode);
        StoragePath path = new StoragePath();
        path.addPathElement(Organization.ORGANIZATION_CODE, organizationCode);
        // Check required fields
        if(organization.isValid()) {
            try {
                organizationStorage.update(path, organization);
            } catch (StorageException ex) {
                return Response.status(Response.Status.BAD_REQUEST).entity(ex.getMessage()).build();
            }
            return Response.noContent().build();
        } else {
            return Response.status(Response.Status.BAD_REQUEST).entity("Organization Code not found").build();
        }
    }

    @Path("/{organizationCode}")
    @DELETE
    @Consumes(MediaType.APPLICATION_JSON)
    public Response deleteOrganization(@PathParam(Organization.ORGANIZATION_CODE) String organizationCode) {
        StoragePath path = new StoragePath();
        path.addPathElement(Organization.ORGANIZATION_CODE, organizationCode);
        try {
            organizationStorage.deleteByPath(path);
        } catch (StorageException ex) {
            return Response.status(Response.Status.BAD_REQUEST).entity(ex.getMessage()).build();
        }
        return Response.noContent().build();
    }
}

