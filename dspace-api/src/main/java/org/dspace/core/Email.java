/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.core;

import org.apache.log4j.Logger;

import java.io.File;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;

import javax.activation.DataHandler;
import javax.activation.FileDataSource;
import javax.mail.Address;
import javax.mail.Authenticator;
import javax.mail.BodyPart;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;

/**
 * Class representing an e-mail message, also used to send e-mails.
 * <P>
 * Typical use:
 * <P>
 * <code>Email email = ConfigurationManager.getEmail(name);</code><br>
 * <code>email.addRecipient("foo@bar.com");</code><br>
 * <code>email.addArgument("John");</code><br>
 * <code>email.addArgument("On the Testing of DSpace");</code><br>
 * <code>email.send();</code><br>
 * <P>
 * <code>name</code> is the name of an email template in
 * <code>dspace-dir/config/emails/</code> (which also includes the subject.)
 * <code>arg0</code> and <code>arg1</code> are arguments to fill out the
 * message with.
 * <P>
 * Emails are formatted using <code>java.text.MessageFormat.</code>
 * Additionally, comment lines (starting with '#') are stripped, and if a line
 * starts with "Subject:" the text on the right of the colon is used for the
 * subject line. For example:
 * <P>
 * 
 * <pre>
 *    
 *     # This is a comment line which is stripped
 *     #
 *     # Parameters:   {0}  is a person's name
 *     #               {1}  is the name of a submission
 *     #
 *     Subject: Example e-mail
 *    
 *     Dear {0},
 *    
 *     Thank you for sending us your submission &quot;{1}&quot;.
 *     
 * </pre>
 * 
 * <P>
 * If the example code above was used to send this mail, the resulting mail
 * would have the subject <code>Example e-mail</code> and the body would be:
 * <P>
 * 
 * <pre>
 *    
 *    
 *     Dear John,
 *    
 *     Thank you for sending us your submission &quot;On the Testing of DSpace&quot;.
 *     
 * </pre>
 * 
 * <P>
 * Note that parameters like <code>{0}</code> cannot be placed in the subject
 * of the e-mail; they won't get filled out.
 * 
 * 
 * @author Robert Tansley
 * @author Jim Downing - added attachment handling code
 * @version $Revision$
 */
public class Email
{
    /*
     * Implementation note: It might be necessary to add a quick utility method
     * like "send(to, subject, message)". We'll see how far we get without it -
     * having all emails as templates in the config allows customisation and 
     * internationalisation.
     * 
     * Note that everything is stored and the run in send() so that only send()
     * throws a MessagingException.
     */

    /** The content of the message */
    private String content;

    /** The subject of the message */
    private String subject;

    /** The arguments to fill out */
    private List<Object> arguments;

    /** The recipients */
    private List<String> recipients;

    /** Reply to field, if any */
    private String replyTo;

    private List<FileAttachment> attachments;

    /** The character set this message will be sent in */
    private String charset;

    private static final Logger log = Logger.getLogger(Email.class);

    /**
     * Create a new email message.
     */
    Email()
    {
        arguments = new ArrayList<Object>(50);
        recipients = new ArrayList<String>(50);
        attachments = new ArrayList<FileAttachment>(10);
        subject = "";
        content = "";
        replyTo = null;
        charset = null;
    }

    /**
     * Add a recipient
     * 
     * @param email
     *            the recipient's email address
     */
    public void addRecipient(String email)
    {
        recipients.add(email);
    }

    /**
     * Set the content of the message. Setting this "resets" the message
     * formatting -<code>addArgument</code> will start. Comments and any
     * "Subject:" line must be stripped.
     * 
     * @param cnt
     *            the content of the message
     */
    void setContent(String cnt)
    {
        content = cnt;
        arguments = new ArrayList<Object>();
    }

    /**
     * Set the subject of the message
     * 
     * @param s
     *            the subject of the message
     */
    void setSubject(String s)
    {
        subject = s;
    }

    /**
     * Set the reply-to email address
     * 
     * @param email
     *            the reply-to email address
     */
    public void setReplyTo(String email)
    {
        replyTo = email;
    }

    /**
     * Fill out the next argument in the template
     * 
     * @param arg
     *            the value for the next argument
     */
    public void addArgument(Object arg)
    {
        arguments.add(arg);
    }

    public void addAttachment(File f, String name)
    {
        attachments.add(new FileAttachment(f, name));
    }

    public void setCharset(String cs)
    {
        charset = cs;
    }

    /**
     * "Reset" the message. Clears the arguments and recipients, but leaves the
     * subject and content intact.
     */
    public void reset()
    {
        arguments = new ArrayList<Object>(50);
        recipients = new ArrayList<String>(50);
        attachments = new ArrayList<FileAttachment>(10);
        replyTo = null;
        charset = null;
    }

    /**
     * Sends the email.
     * 
     * @throws MessagingException
     *             if there was a problem sending the mail.
     */
    public void send() throws MessagingException
    {
        // Get the mail configuration properties
        String server = ConfigurationManager.getProperty("mail.server");
        String from = ConfigurationManager.getProperty("mail.from.address");
        boolean disabled = ConfigurationManager.getBooleanProperty("mail.server.disabled", false);

        if (disabled) {
            log.info("message not sent due to mail.server.disabled: " + subject);
            return;
        }

        // Set up properties for mail session
        Properties props = System.getProperties();
        props.put("mail.smtp.host", server);

        // Set the port number for the mail server
        String portNo = ConfigurationManager.getProperty("mail.server.port");
        if (portNo == null)
        {
        	portNo = "25";
        }
        props.put("mail.smtp.port", portNo.trim());

        // If no character set specified, attempt to retrieve a default
        if (charset == null)
        {
            charset = ConfigurationManager.getProperty("mail.charset");    
        }

        // Get session
        Session session;
        
        // Get the SMTP server authentication information
        String username = ConfigurationManager.getProperty("mail.server.username");
        String password = ConfigurationManager.getProperty("mail.server.password");
        
        if (username != null)
        {
            props.put("mail.smtp.auth", "true");
            SMTPAuthenticator smtpAuthenticator = new SMTPAuthenticator(
                    username, password);
            session = Session.getDefaultInstance(props, smtpAuthenticator);
        }
        else
        {
            session = Session.getDefaultInstance(props);
        }

        // Set extra configuration properties
        String extras = ConfigurationManager.getProperty("mail.extraproperties");
        if ((extras != null) && (!"".equals(extras.trim())))
        {
            String arguments[] = extras.split(",");
            String key, value;
            for (String argument : arguments)
            {
                key = argument.substring(0, argument.indexOf('=')).trim();
                value = argument.substring(argument.indexOf('=') + 1).trim();
                props.put(key, value);
            }
        }

        // Create message
        MimeMessage message = new MimeMessage(session);

        // Set the recipients of the message
        Iterator<String> i = recipients.iterator();

        while (i.hasNext())
        {
            message.addRecipient(Message.RecipientType.TO, new InternetAddress(
                    i.next()));
        }

        // Format the mail message
        Object[] args = arguments.toArray();
        String fullMessage = MessageFormat.format(content, args);
        Date date = new Date();

        message.setSentDate(date);
        message.setFrom(new InternetAddress(from));

        // Set the subject of the email (may contain parameters)
        String fullSubject = MessageFormat.format(subject, args);
        if (charset != null)
        {
            message.setSubject(fullSubject, charset);
        }
        else
        {
            message.setSubject(fullSubject);
        }
        
        // Add attachments
        if (attachments.isEmpty())
        {
            // If a character set has been specified, or a default exists
            if (charset != null)
            {
                message.setText(fullMessage, charset);
            }
            else
            {
                message.setText(fullMessage);
            }
        }
        else
        {
            Multipart multipart = new MimeMultipart();
            // create the first part of the email
            BodyPart messageBodyPart = new MimeBodyPart();
            messageBodyPart.setText(fullMessage);
            multipart.addBodyPart(messageBodyPart);

            for (Iterator<FileAttachment> iter = attachments.iterator(); iter.hasNext();)
            {
                FileAttachment f = iter.next();
                // add the file
                messageBodyPart = new MimeBodyPart();
                messageBodyPart.setDataHandler(new DataHandler(
                        new FileDataSource(f.file)));
                messageBodyPart.setFileName(f.name);
                multipart.addBodyPart(messageBodyPart);
            }
            message.setContent(multipart);
        }

        if (replyTo != null)
        {
            Address[] replyToAddr = new Address[1];
            replyToAddr[0] = new InternetAddress(replyTo);
            message.setReplyTo(replyToAddr);
        }

        log.debug("sending email with subject \'" + fullSubject + "\' to recipients " + recipients.toString() + " with content \'" + fullMessage + "\'");
        Transport.send(message);
    }

    public String toString() {
        return "recipients: " + recipients.toString() + ", message: " + content;
    }

    /**
     * Test method to send an email to check email server settings
     *
     * @param args Command line options
     */
    public static void main(String[] args)
    {
        String to = ConfigurationManager.getProperty("mail.admin");
        String subject = "DSpace test email";
        String server = ConfigurationManager.getProperty("mail.server");
        String url = ConfigurationManager.getProperty("dspace.url");
        Email e = new Email();
        e.setSubject(subject);
        e.addRecipient(to);
        e.content = "This is a test email sent from DSpace: " + url;
        System.out.println("\nAbout to send test email:");
        System.out.println(" - To: " + to);
        System.out.println(" - Subject: " + subject);
        System.out.println(" - Server: " + server);
        try
        {
            e.send();
        }
        catch (MessagingException me)
        {
            System.err.println("\nError sending email:");
            System.err.println(" - Error: " + me);
            System.err.println("\nPlease see the DSpace documentation for assistance.\n");
            System.err.println("\n");
            System.exit(1);
        }
        System.out.println("\nEmail sent successfully!\n");
    }

    /**
     * Utility struct class for handling file attachments.
     * 
     * @author ojd20
     * 
     */
    private static class FileAttachment
    {
        public FileAttachment(File f, String n)
        {
            this.file = f;
            this.name = n;
        }

        File file;

        String name;
    }
    
    /**
     * Inner Class for SMTP authentication information
     */
    private static class SMTPAuthenticator extends Authenticator
    {
        // User name
        private String name;
        
        // Password
        private String password;
        
        public SMTPAuthenticator(String n, String p)
        {
            name = n;
            password = p;
        }
        
        protected PasswordAuthentication getPasswordAuthentication()
        {
            return new PasswordAuthentication(name, password);
        }
    }
}
