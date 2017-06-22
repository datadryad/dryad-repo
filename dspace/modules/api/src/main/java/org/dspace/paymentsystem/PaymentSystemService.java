/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.paymentsystem;

import org.dspace.app.xmlui.wing.WingException;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.DSpaceObject;
import org.dspace.core.Context;
import org.dspace.workflow.WorkflowItem;

import java.sql.SQLException;
import java.util.Map;

/**
 * PaymentService provides an interface for the DSpace application to
 * interact with the Payment Service implementation.
 *
 * @author Mark Diggory, mdiggory at atmire.com
 * @author Fabio Bolognesi, fabio at atmire.com
 * @author Lantian Gai, lantian at atmire.com
 */
public interface PaymentSystemService
{
    public void modifyShoppingCart(Context context, ShoppingCart transaction, DSpaceObject dso) throws AuthorizeException, SQLException, PaymentSystemException;

    public void deleteShoppingCart(Context context, Integer transactionId) throws AuthorizeException, SQLException, PaymentSystemException;

    public ShoppingCart getShoppingCart(Context context, Integer transactionId) throws SQLException;

    public ShoppingCart getShoppingCartByItemId(Context context, Integer itemId) throws SQLException,PaymentSystemException;

    public void generateShoppingCart(Context context,org.dspace.app.xmlui.wing.element.List info,ShoppingCart transaction,PaymentSystemConfigurationManager manager,String baseUrl,Map<String,String> messages) throws WingException,SQLException;
    public void generateNoEditableShoppingCart(Context context,org.dspace.app.xmlui.wing.element.List info,ShoppingCart transaction,PaymentSystemConfigurationManager manager,String baseUrl,Map<String,String> messages) throws WingException,SQLException;

    public void sendPaymentApprovedEmail(Context c, WorkflowItem wfi, ShoppingCart shoppingCart);
    public void sendPaymentErrorEmail(Context c, WorkflowItem wfi, ShoppingCart shoppingCart, String error);
    public void sendPaymentWaivedEmail(Context c, WorkflowItem wfi, ShoppingCart shoppingCart);
    public void sendPaymentRejectedEmail(Context c, WorkflowItem wfi, ShoppingCart shoppingCart);



    }
