package org.dspace.app.xmlui.aspect.authority.util;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.PosixParser;

import org.apache.commons.httpclient.HttpClient;


import org.apache.commons.httpclient.HttpException;
import org.apache.commons.httpclient.methods.GetMethod;

import org.apache.log4j.Logger;

import org.dspace.content.Item;
import org.dspace.content.authority.AuthorityMetadataValue;
import org.dspace.content.authority.Concept;
import org.dspace.content.authority.Scheme;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;

import java.io.IOException;


/**
 * User: lantian @ atmire . com
 * Date: 7/21/14
 * Time: 2:27 PM
 */
public class LoadCustomerCredit {

    /** DSpace Context object */
    private Context context;

    protected static Logger log = Logger.getLogger(LoadCustomerCredit.class);
    /**
     * For invoking via the command line.  If called with no command line arguments,
     * it will negotiate with the user for the administrator details
     *
     * @param argv
     *            command-line arguments
     */
    public static void main(String[] argv)
            throws Exception
    {
        CommandLineParser parser = new PosixParser();
        Options options = new Options();

        LoadCustomerCredit ca = new LoadCustomerCredit();
        options.addOption("i", "customer id", true, "customer id");
        options.addOption("u", "update credit", false, "update credit");
        options.addOption("d", "deduct credit", false, "deduct credit");
        options.addOption("l", "list customer", false, "list customer");
        CommandLine line = parser.parse(options, argv);
        if(line.hasOption("u"))
        {
            ca.importCredit(line.getOptionValue("i"));

        }
        else if(line.hasOption("d")){
            ca.updateCredit(line.getOptionValue("i"));
        }
        else if(line.hasOption("l")){
            ca.loadCustomerInfo(line.getOptionValue("i"));
        }
        else{
            //load credit
            String credit = ca.loadCredit(line.getOptionValue("i"));
            System.out.println("credit : "+ credit);
        }
    }



    /**
     * constructor, which just creates and object with a ready context
     *
     * @throws Exception
     */
    public LoadCustomerCredit()
            throws Exception
    {

    }

    /**
     * Create the administrator with the given details.  If the user
     * already exists then they are simply upped to administrator status
     *
     * @throws Exception
     */
    public String loadCredit(String customerId)
            throws Exception
    {
        // Of course we aren't an administrator yet so we need to
        // circumvent authorisation

        String credit=null;
        try {


            String requestUrl =  "http://online.datadryad.org/dryaddevsvc/CENCREDWEBSVCLIB.GET_CREDITS_XML?p_input_xml_doc=%3C%3Fxml%20version%3D%221.0%22%20encoding%3D%22UTF-8%22%20%3F%3E%3CcreditRequest%3E%3CintegratorUsername%3EUSERNAME%3C%2FintegratorUsername%3E%3CintegratorPassword%3EPASSWORD%3C%2FintegratorPassword%3E%3CcustId%3EcustomerId%3C%2FcustId%3E%3CtxTy%3EPREPAID%3C%2FtxTy%3E%3C%2FcreditRequest%3E";
            String user = ConfigurationManager.getProperty("association.anywhere.username");
            String pass = ConfigurationManager.getProperty("association.anywhere.password");
            requestUrl = requestUrl.replace("USERNAME",user);
            requestUrl = requestUrl.replace("PASSWORD",pass);

            try {

                String url = requestUrl.replace("customerId",customerId);
                HttpClient client = new HttpClient();

                GetMethod get = new GetMethod(url);

//                    HttpMethodParams params = new HttpMethodParams();
//
//                    params.setParameter("test","test");
//
//                    get.setParams(params);

                client.executeMethod(get);

                if( get.getStatusCode() <= 299 )
                {
                    System.out.println("Response Code : "
                            + get.getStatusLine().getStatusCode());
                    String result = get.getResponseBodyAsString();
                    System.out.println("Response body : "+result);
                    log.info(result);
                    credit = getXmlElement(result,"totCreditsAccepted");

                }


            }
            catch (Exception e) {
                log.error("errors when loading customer credit:", e);
                return null;
            }

        }catch (Exception e)
        {
            System.out.print(e);
            System.out.print(e.getStackTrace());
        }

        return credit;
    }

    public String loadCustomerInfo(String customerId)
            throws Exception
    {

        String customerInfo=null;
        try {


            String requestUrl = "http://online.datadryad.org/dryaddevsvc/CENSSAWEBSVCLIB.GET_CUST_INFO_XML?p_input_xml_doc=%3C%3Fxml%20version%3D%221.0%22%20encoding%3D%22UTF-8%22%3F%3E%3CcustInfoRequest%3E%3CcustId%3EcustomerId%3C%2FcustId%3E%3CintegratorUsername%3EUSERNAME%3C%2FintegratorUsername%3E%3CintegratorPassword%3EPASSWORD%3C%2FintegratorPassword%3E%3Cdetails%20includeCodeValues%3D%22true%22%3E%3Croles%20include%3D%22true%22%20%2F%3E%3Caddresses%20include%3D%22true%22%20includeBad%3D%22true%22%20%2F%3E%3Cphones%20include%3D%22true%22%20%2F%3E%3Cemails%20include%3D%22true%22%20includeBad%3D%22true%22%20%2F%3E%3Cwebsites%20include%3D%22true%22%20includeBad%3D%22true%22%20%2F%3E%3Cjobs%20include%3D%22true%22%20includeInactive%3D%22true%22%20%2F%3E%3CcommitteePositions%20include%3D%22true%22%20includeInactive%3D%22true%22%20%2F%3E%3Cmemberships%20include%3D%22true%22%20includeInactive%3D%22true%22%20%2F%3E%3Csubscriptions%20include%3D%22true%22%20includeExpired%3D%22true%22%20%2F%3E%3CcommunicationPreferences%20include%3D%22true%22%20%2F%3E%3CcustomerAttributes%20include%3D%22true%22%20includeAll%3D%22true%22%3E%3C%2FcustomerAttributes%3E%3Cbio%20include%3D%22true%22%20%2F%3E%3C%2Fdetails%3E%3C%2FcustInfoRequest%3E";
            String user = ConfigurationManager.getProperty("association.anywhere.username");
            String pass = ConfigurationManager.getProperty("association.anywhere.password");
            requestUrl = requestUrl.replace("USERNAME",user);
            requestUrl = requestUrl.replace("PASSWORD",pass);
            try {

                String url = requestUrl.replace("customerId",customerId);
                HttpClient client = new HttpClient();

                GetMethod get = new GetMethod(url);

                client.executeMethod(get);

                if( get.getStatusCode() <= 299 )
                {
                    System.out.println("Response Code : "
                            + get.getStatusLine().getStatusCode());
                    String result = get.getResponseBodyAsString();
                    System.out.println("Response body : "+result);
                    customerInfo= result;

                }

            }
            catch (Exception e) {
                log.error("errors when loading customer information:", e);
                return null;
            }

        }catch (Exception e)
        {
            System.out.print(e);
            System.out.print(e.getStackTrace());
        }

        return customerInfo;
    }


    public static String updateCredit(String customerId) throws LoadCustomerCreditException {
        // Of course we aren't an administrator yet so we need to
        // circumvent authorisation
        if (ConfigurationManager.getBooleanProperty("credit.test.mode")) {
            throw new LoadCustomerCreditException("testing failure");
        }

        String status = null;

        String requestUrl = "http://online.datadryad.org/dryaddevsvc/CENCREDWEBSVCLIB.INS_CREDIT_XML?p_input_xml_doc=%3C%3Fxml%20version%3D%221.0%22%20encoding%3D%22UTF-8%22%20%3F%3E%3Ccredit-request%3E%3Cvendor-id%3EUSERNAME%3C%2Fvendor-id%3E%3Cvendor-password%3EPASSWORD%3C%2Fvendor-password%3E%3Ccust-id%3EcustomerId%3C%2Fcust-id%3E%3Ctrans-type%3EDEFERRED%3C%2Ftrans-type%3E%3Ctrans-date%3E04%2F14%2F2014%3C%2Ftrans-date%3E%3Ccred-accepted%3E-1%3C%2Fcred-accepted%3E%3C%2Fcredit-request%3E";
        String user = ConfigurationManager.getProperty("association.anywhere.username");
        String pass = ConfigurationManager.getProperty("association.anywhere.password");
        requestUrl = requestUrl.replace("USERNAME",user);
        requestUrl = requestUrl.replace("PASSWORD",pass);
        try {
            String url = requestUrl.replace("customerId", customerId);
            HttpClient client = new HttpClient();

            GetMethod get = new GetMethod(url);

            client.executeMethod(get);

            if (get.getStatusCode() <= 299) {
                log.debug("Response Code : "
                        + get.getStatusLine().getStatusCode());
                String result = get.getResponseBodyAsString();
                log.debug("Response body : " + result);
                status = getXmlElement(result, "credit-update-status");
                status = getXmlElement(status, "status");
                if("FAILURE".equals(status))
                {
                    throw new LoadCustomerCreditException(result);
                }
            }

            return status;
        } catch (HttpException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
            throw new LoadCustomerCreditException(e.getMessage(),e);
        } catch (IOException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
            throw new LoadCustomerCreditException(e.getMessage(),e);
        } catch (Exception e)
        {
            throw new LoadCustomerCreditException(e.getMessage());
        }

    }


    public void importCredit(String customerId)
            throws Exception
    {
        if(context==null)
        {
            context = new Context();
        }
        //internal.journal.integrated
        //internal.journal.sponsorName
        //internal.journal.subscriptionPaid
        //internal.journal.paymentPlanType

        if(customerId!=null)
        {
            String credit = loadCredit(customerId);
            String customerInfo = loadCustomerInfo(customerId);
            String customerName = getXmlElement(customerInfo,"displayName");
            Scheme scheme = Scheme.findByIdentifier(context,ConfigurationManager.getProperty("solrauthority.searchscheme.prism_publicationName"));
            Concept[] concepts = Concept.findByPreferredLabel(context,customerName,scheme.getID());
            for(Concept concept:concepts)
            {
                //set integrated, make sure integrated is true
                changeConceptMetadataValue(concept,"customerId",customerId);
                changeConceptMetadataValue(concept,"integrated","true");

                String classSubclassDescr = getXmlElement(customerInfo,"classSubclassDescr");
                if(classSubclassDescr!=null&&classSubclassDescr.contains("Subscription"))
                {
                    String statusCode = getXmlElement(customerInfo,"statusCode");
                    if(statusCode!=null&&statusCode.contains("ACTIVE"))
                    {
                        //set journal.submissionPaid=true and journal paymentPlanType=subscription
                        changeConceptMetadataValue(concept,"subscriptionPaid","true");
                        changeConceptMetadataValue(concept,"paymentPlanType","subscription");
                    }
                    else
                    {
                        //journal.submissionPaid=false and journal paymentPlanType=null
                        changeConceptMetadataValue(concept,"subscriptionPaid","false");
                        changeConceptMetadataValue(concept,"paymentPlanType","");
                    }

                }
                else if(classSubclassDescr!=null&&classSubclassDescr.contains("Deferred"))
                {
                    String statusCode = getXmlElement(customerInfo,"statusCode");
                    if(statusCode!=null&&statusCode.contains("ACTIVE"))
                    {
                        //set submissionPaid=true and paymentPlanType=deferred
                        changeConceptMetadataValue(concept,"subscriptionPaid","true");
                        changeConceptMetadataValue(concept,"paymentPlanType","deferred");
                    }
                    else
                    {
                        //journal.submissionPaid=false and journal paymentPlanType=null
                        changeConceptMetadataValue(concept,"subscriptionPaid","false");
                        changeConceptMetadataValue(concept,"paymentPlanType","");
                    }
                }
                else
                {
                    if(credit!=null&&Integer.parseInt(credit)>0)
                    {
                        //set submissionPaid=true and paymentPlanType=null
                        changeConceptMetadataValue(concept,"subscriptionPaid","true");
                        changeConceptMetadataValue(concept,"paymentPlanType","");
                    }
                    else
                    {
                        changeConceptMetadataValue(concept,"subscriptionPaid","false");
                        changeConceptMetadataValue(concept,"paymentPlanType","");
                    }
                }

                concept.update();
                context.commit();
            }

        }
        else
        {
            String[] customers = new String[]{"1230779","1230688","1237215"};
            for(String customer:customers)
            {
                importCredit(customer);
            }
        }
    }

    public static String getXmlElement(String result,String key)
    {
        String info = null;
        int start = result.indexOf(key);
        int end = result.lastIndexOf(key);
        System.out.println("start : "+start+", end"+end);
        if(start>0&&end>0){
            info = result.substring(start+key.length()+1,end-2);
            //<![CDATA[Molecular Ecology]]>
            info = info.replace("<![CDATA[","");
            info = info.replace("]]>","");
        }
        else
        {
            log.error("error when loading customer credit");
        }
        return info;




        //
//                        DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
//                        DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
//                        InputSource is = new InputSource(get.getResponseBodyAsStream());
//                        Document docResponse = docBuilder.parse(is);
//                        NodeList errors=  docResponse.getElementsByTagName("errors");
//                        if(errors!=null)
//                        {
//                            int i = 0;
//                            while(i < errors.getLength())
//                            {
//                                Node error = errors.item(i);
//                                String value = error.getNodeValue();
//                                log.error("error in loading client credit : "+ value);
//                                i++;
//                            }
//                            log.error("errors when loading customer credit:"+result);
//                        }
//                        else{
//                            NodeList list = docResponse.getElementsByTagName("totCreditsAccepted");
//                            if(list!=null&&list.item(0)!=null)
//                            {
//                                credit = list.item(0).getTextContent();
//                            }
//                        }
    }

    public void changeConceptMetadataValue(Concept concept,String field,String value)
    {
        AuthorityMetadataValue[] metadataValues = concept.getMetadata("internal","journal",field, Item.ANY);
        if(metadataValues==null||metadataValues.length==0)
        {
            concept.addMetadata("internal","journal",field,"en",value,null,-1);
        }
        else{

            for(AuthorityMetadataValue authorityMetadataValue:metadataValues)
            {
                if(!authorityMetadataValue.value.equals(value))
                {
                    concept.clearMetadata("internal","journal",field, Item.ANY);
                    concept.addMetadata("internal","journal",field,"en",value,null,-1);
                    break;
                }
            }
        }
    }
}

