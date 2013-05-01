/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.dspace.app.xmlui.aspect.dryadwidgets;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import org.apache.avalon.framework.parameters.Parameters;
import org.apache.cocoon.acting.Action;
import org.apache.cocoon.environment.Redirector;
import org.apache.cocoon.environment.SourceResolver;

/**
 * This action returns a data package DOI for a given article if a package exists.
 * The data package DOI is returned in the map, which can be used further down
 * in the cocoon pipeline
 * The publisher parameter must be provided, but is not currently recorded here.
 *
 * @author Dan Leehr
 */
public class WidgetBannerAction extends WidgetBannerLookup implements Action {
    private static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger(WidgetBannerAction.class);

    @Override
    public Map act(Redirector redirector, SourceResolver resolver, Map objectModel, String source, Parameters parameters) throws Exception {
            String publisher = parameters.getParameter("publisher","");
            String articleDOI = parameters.getParameter("identifier","");
            String packageDOI = null;
        try {
            packageDOI = lookup(articleDOI, publisher, objectModel);
        } catch (SQLException ex) {
            log.error("Error looking up article DOI:", ex);
        }
        Map returnMap = new HashMap();
        returnMap.put("package", packageDOI);
        return returnMap;
    }
}
