package org.dspace.content.authority;

import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.response.QueryResponse;

import java.net.MalformedURLException;
import java.util.List;

/**
 * Search API for Solr based Authority Control Service.
 *
 * @author Lantian Gai, Mark Diggory, Kevin Van de Velde
 */
public interface AuthoritySearchService {

    QueryResponse search(SolrQuery query) throws SolrServerException, MalformedURLException;

    List<String> getAllIndexedMetadataFields() throws Exception;

}
