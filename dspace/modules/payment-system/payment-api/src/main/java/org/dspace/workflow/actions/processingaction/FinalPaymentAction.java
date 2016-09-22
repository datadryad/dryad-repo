/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.workflow.actions.processingaction;

import org.apache.log4j.Logger;
import org.datadryad.anywhere.AssociationAnywhere;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Item;
import org.dspace.content.authority.AuthorityMetadataValue;
import org.dspace.content.authority.Concept;
import org.dspace.content.authority.Scheme;
import org.dspace.core.*;
import org.dspace.identifier.DOIIdentifierProvider;
import org.dspace.paymentsystem.PaymentSystemService;
import org.dspace.paymentsystem.PaymentService;
import org.dspace.paymentsystem.ShoppingCart;
import org.dspace.paymentsystem.Voucher;
import org.dspace.utils.DSpace;
import org.dspace.workflow.*;
import org.dspace.workflow.actions.ActionResult;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Date;


/**
 *  This action completes the final payment if the shopping cart has a valid
 *  transaction id present. In the event htat the transaction should fail, this step will
 *  forward the user to the ReAuthorizationPayment step, which will provide them with
 *  an opportunity to initiate a new payment.
 *
 * @author Mark Diggory, mdiggory at atmire.com
 * @author Fabio Bolognesi, fabio at atmire.com
 * @author Lantian Gai, lantian at atmire.com
 */
public class FinalPaymentAction extends ProcessingAction {

    private static Logger log = Logger.getLogger(FinalPaymentAction.class);



    @Override
    public void activate(Context c, WorkflowItem wfItem) {}

    @Override
    public ActionResult execute(Context c, WorkflowItem wfi, Step step, HttpServletRequest request) throws SQLException, AuthorizeException, IOException {
	int itemID =  wfi.getItem().getID();
	log.info("Verifying payment status of Item " + itemID);
	
        try{
	    PaymentSystemService paymentSystemService = new DSpace().getSingletonService(PaymentSystemService.class);   
	    ShoppingCart shoppingCart = paymentSystemService.getShoppingCartByItemId(c,itemID);

	    // if fee waiver is in place, transaction is paid
	    if(shoppingCart.getCountry() != null && shoppingCart.getCountry().length() > 0) {
		log.info("processed fee waiver for Item " + itemID + ", country = " + shoppingCart.getCountry());
		return new ActionResult(ActionResult.TYPE.TYPE_OUTCOME, ActionResult.OUTCOME_COMPLETE);
	    }


        // if a valid voucher is in place, transaction is paid
        Voucher voucher = Voucher.findById(c,shoppingCart.getVoucher());
        log.debug("voucher is " + voucher);
        if(voucher != null) {
            log.debug("voucher status " + voucher.getStatus());
            if(voucher.getStatus().equals(Voucher.STATUS_OPEN)) {
                voucher.setStatus(Voucher.STATUS_USED);
                voucher.update();
                c.commit();
                log.info("processed voucher for Item " + itemID + ", voucherID = " + voucher.getID());
                return new ActionResult(ActionResult.TYPE.TYPE_OUTCOME, ActionResult.OUTCOME_COMPLETE);
            }
        }

	// if journal-based subscription is in place, transaction is paid
	if(shoppingCart.getJournalSub()) {
	    log.info("processed journal subscription for Item " + itemID + ", journal = " + shoppingCart.getJournal());
	    log.debug("tally credit for journal = " + shoppingCart.getJournal());
	    String success = "";
	    Scheme scheme = Scheme.findByIdentifier(c,ConfigurationManager.getProperty("solrauthority.searchscheme.prism_publicationName"));
	    Concept[] concepts = Concept.findByPreferredLabel(c,shoppingCart.getJournal(),scheme.getID());
	    if(concepts!=null&&concepts.length!=0){
		AuthorityMetadataValue[] metadataValues = concepts[0].getMetadata("journal", "customerID", null, Item.ANY);
            if (metadataValues!=null&&metadataValues.length>0) {
                try {
                    String packageDOI = DOIIdentifierProvider.getDoiValue(wfi.getItem());
                    shoppingCart.setStatus(ShoppingCart.STATUS_COMPLETED);
                    Date date= new Date();
                    shoppingCart.setPaymentDate(date);
                    shoppingCart.update();
                    success = AssociationAnywhere.tallyCredit(c, metadataValues[0].value, packageDOI);
                    paymentSystemService.sendPaymentApprovedEmail(c,wfi,shoppingCart);
                    return new ActionResult(ActionResult.TYPE.TYPE_OUTCOME, ActionResult.OUTCOME_COMPLETE);
                } catch (Exception e) {
                    log.error(e.getMessage(),e);
                    paymentSystemService.sendPaymentErrorEmail(c, wfi, shoppingCart, "problem: credit not tallied successfully. \\n \\n " + e.getMessage());
                    return new ActionResult(ActionResult.TYPE.TYPE_OUTCOME, 2);
                }
            } else {
                log.error("unable to tally credit due to missing customerID");
            }
	    } else {
		    log.error("unable to tally credit due to missing concept");
	    }
	}

			  

	    
	    // process payment via PayPal
            PaymentService paymentService = new DSpace().getSingletonService(PaymentService.class);
            if(paymentService.submitReferenceTransaction(c,wfi,request)){
		log.info("processed PayPal payment for Item " + itemID);
                return new ActionResult(ActionResult.TYPE.TYPE_OUTCOME, ActionResult.OUTCOME_COMPLETE);
            }


        } catch (Exception e){
            log.error(e.getMessage(),e);
        }

        //Send us to the re authorization of paypal payment
	log.info("no payment processded for Item " + itemID + ", sending to revalidation step");
        WorkflowEmailManager.notifyOfReAuthorizationPayment(c, wfi);
        return new ActionResult(ActionResult.TYPE.TYPE_OUTCOME, 1);

    }
}
