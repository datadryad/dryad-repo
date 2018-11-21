package org.datadryad.api;

/** 
    Utilities to facilitate communication with the DASH-based version of Dryad.

    To use from the command line:
    - retrieve an item from Dash:
      /opt/dryad/bin/dspace dash-service <doi>
 **/

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintStream;
import java.io.StringWriter;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.Arrays;
import java.util.Base64;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.apache.log4j.Logger;
import org.datadryad.api.DryadDataFile;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import org.dspace.content.Bitstream;

public class DashService {

    private static final Logger log = Logger.getLogger(DashService.class);
    private String dashServer = "";
    private String oauthToken = "";

    public DashService() {
        // init oauth connection with DASH
        dashServer = ConfigurationManager.getProperty("dash.server");
        String dashAppID = ConfigurationManager.getProperty("dash.application.id");
        String dashAppSecret = ConfigurationManager.getProperty("dash.application.secret");
        
        oauthToken = getOAUTHtoken(dashServer, dashAppID, dashAppSecret);
        fixHttpURLConnection();
    }

    /**
       Fix the fact that HttpURLConnection doesn't natively allow PATCH requests.

       This will be "fixed" by replacement classes in Java 11. See https://bugs.openjdk.java.net/browse/JDK-8207840
       Fix adapted from code at https://stackoverflow.com/questions/25163131/httpurlconnection-invalid-http-method-patch
     **/
    private static void fixHttpURLConnection() {
        try {
            Field methodsField = HttpURLConnection.class.getDeclaredField("methods");

            Field modifiersField = Field.class.getDeclaredField("modifiers");
            modifiersField.setAccessible(true);
            modifiersField.setInt(methodsField, methodsField.getModifiers() & ~Modifier.FINAL);

            methodsField.setAccessible(true);

            String[] oldMethods = (String[]) methodsField.get(null);
            Set<String> methodsSet = new LinkedHashSet<>(Arrays.asList(oldMethods));
            methodsSet.add("PATCH");
            String[] newMethods = methodsSet.toArray(new String[0]);

            methodsField.set(null/*static field*/, newMethods);
        } catch (NoSuchFieldException | IllegalAccessException e) {
            throw new IllegalStateException(e);
        }
    }
    
    private String getOAUTHtoken(String dashServer, String dashAppID, String dashAppSecret) {
        
        String url = dashServer + "/oauth/token";
        String auth = dashAppID + ":" + dashAppSecret;
        String authentication = Base64.getEncoder().encodeToString(auth.getBytes());
        Pattern tokenPattern = Pattern.compile(".*\"access_token\"\\s*:\\s*\"([^\"]+)\".*");
        String token = "";

        try {
            URL urlObj = new URL(url);
            HttpURLConnection con = (HttpURLConnection) urlObj.openConnection();
            con.setRequestMethod("POST");
            con.setDoOutput(true);
            con.setRequestProperty("Authorization", "Basic " + authentication);
            con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=UTF-8");
            con.setRequestProperty("Accept", "application/json");
            
            PrintStream os = new PrintStream(con.getOutputStream());
            os.print("grant_type=client_credentials");
            os.close();

            InputStream stream = con.getErrorStream();
            if (stream == null) {
                stream = con.getInputStream();
            }                                         
            BufferedReader reader = new BufferedReader(new InputStreamReader(stream));
            String line = null;
            StringWriter out = new StringWriter(con.getContentLength() > 0 ? con.getContentLength() : 2048);
            while ((line = reader.readLine()) != null) {
                out.append(line);
            }
            String response = out.toString();
            Matcher matcher = tokenPattern.matcher(response);
            if (matcher.matches() && matcher.groupCount() > 0) {
                token = matcher.group(1);
            }

            log.info("got OAuth token " + token);

        } catch (Exception e) {
            log.fatal("Unable to obtain OAuth token", e);
        }

        return token;
    }

    /**
       Read the JSON format of a dataset from Dash.
    **/
    public String getDashJSON(String doi) {
        String response = "";
        log.debug("getting Dash JSON for " + doi);
        
        try {
            doi = URLEncoder.encode(doi, "UTF-8");
            URL url = new URL(dashServer + "/api/datasets/" + doi);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            connection.setRequestProperty("Accept", "application/json");
            connection.setRequestProperty("Authorization", "Bearer " + oauthToken);

            InputStream stream = connection.getErrorStream();
            if (stream == null) {
                stream = connection.getInputStream();
            }                                         
            BufferedReader reader = new BufferedReader(new InputStreamReader(stream));
            String line = null;
            StringWriter responseContent = new StringWriter(connection.getContentLength() > 0 ? connection.getContentLength() : 2048);
            while ((line = reader.readLine()) != null) {
                responseContent.append(line);
            }
            response = responseContent.toString();
            log.debug("got response content: " + responseContent);
        } catch (Exception e) {
            log.error("Unable to get Dash JSON", e);
        }
        
        return response;
    }


    /**
       PUTs a DryadDataPackage to Dash, creating a new submission or updating an
       existing submission (using the DOI contained in the Data Package).

       @return a HTTP response code
    **/
    public int putDataPackage(DryadDataPackage dataPackage) {
        String dashJSON = dataPackage.getDashJSON();
        log.debug("Got JSON object: " + dashJSON);
        int responseCode = 0;
        BufferedReader reader = null;
        
        try {
            String encodedDOI = URLEncoder.encode(dataPackage.getIdentifier(), "UTF-8");
            URL url = new URL(dashServer + "/api/datasets/" + encodedDOI);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            connection.setRequestProperty("Accept", "application/json");
            connection.setRequestProperty("Authorization", "Bearer " + oauthToken);
            connection.setDoOutput(true);
            connection.setRequestMethod("PUT");

            OutputStreamWriter wr = new OutputStreamWriter(connection.getOutputStream());
            wr.write(dashJSON);
            wr.close();

            InputStream stream = connection.getErrorStream();
            if (stream == null) {
                stream = connection.getInputStream();
            }                                         
            reader = new BufferedReader(new InputStreamReader(stream));
            String line = null;
            StringWriter out = new StringWriter(connection.getContentLength() > 0 ? connection.getContentLength() : 2048);
            while ((line = reader.readLine()) != null) {
                out.append(line);
            }
            String response = out.toString();
            
            responseCode = connection.getResponseCode();

            if(responseCode == 200 || responseCode == 201 || responseCode == 202) {
                log.debug("package create/update successful");
                dataPackage.addDashTransferDate();
            } else {
                log.fatal("Unable to send item to DASH, response: " + responseCode +
                          connection.getResponseMessage());
            }
            
            log.info("result object " + response);
        } catch (Exception e) {
            log.fatal("Unable to send item to DASH", e);
        }

        return responseCode;
    }

    /**
       POSTs references for all data files to Dash, attaching them to the DryadDataPackage.
       The DryadDataPackage must already have been PUT to Dash.

       @return a HTTP response code, or -1 if there is an exception that prevents getting a response code
    **/
    public int postDataFileReferences(Context context, DryadDataPackage dataPackage) {
        int responseCode = 0;
        BufferedReader reader = null;
        log.debug("posting data file references");
        try {
            log.debug("number of files: " + dataPackage.getDataFiles(context).size());
            for(DryadDataFile dryadFile : dataPackage.getDataFiles(context)) {
                String fileName = dryadFile.getTitle();
                String fileDescription = dryadFile.getDescription();
                for(Bitstream dspaceBitstream : dryadFile.getAllBitstreams()) {
                    log.debug("transferring bitstream " + dspaceBitstream.getName());
                    DryadBitstream dryadBitstream = new DryadBitstream(dspaceBitstream);
                    dryadBitstream.setFileDescription(fileDescription);
                    String dashJSON = dryadBitstream.getDashReferenceJSON();
                    log.debug("Got JSON object: " + dashJSON);
                    String encodedPackageDOI = URLEncoder.encode(dataPackage.getIdentifier(), "UTF-8");
                    URL url = new URL(dashServer + "/api/datasets/" + encodedPackageDOI + "/urls");
                    HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                    connection.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
                    connection.setRequestProperty("Accept", "application/json");
                    connection.setRequestProperty("Authorization", "Bearer " + oauthToken);
                    connection.setDoOutput(true);
                    connection.setRequestMethod("POST");
                    
                    OutputStreamWriter wr = new OutputStreamWriter(connection.getOutputStream());
                    wr.write(dashJSON);
                    wr.close();

                    responseCode = connection.getResponseCode();
                    log.info("response code = " + responseCode);
                    
                    InputStream stream = connection.getErrorStream();
                    if (stream == null) {
                        stream = connection.getInputStream();
                    }                                         
                    reader = new BufferedReader(new InputStreamReader(stream));
                    String line = null;
                    StringWriter out = new StringWriter(connection.getContentLength() > 0 ? connection.getContentLength() : 2048);
                    while ((line = reader.readLine()) != null) {
                        out.append(line);
                    }
                    String response = out.toString();
                    log.info("result object " + response);
                    
                    if(responseCode == 200 || responseCode == 201 || responseCode == 202) {
                        log.debug("file create/update successful");
                    } else {
                        log.fatal("Unable to send file reference to DASH, response: " + responseCode +
                                  connection.getResponseMessage());
                        return responseCode;
                    }                    
                }
            }
        } catch (Exception e) {
            log.fatal("Unable to send item to DASH", e);
            return -1;
        }       
            
        return responseCode;
    }

    
    /**
       Given the (unencoded) DOI of a Dryad Data Package that has
       already been transferred to DASH, force the DASH dataset into
       "submitted" status.
     **/
    public int submitDashDataset(String doi) {
        int responseCode = 0;
        BufferedReader reader = null;

        String submissionsFinalize = ConfigurationManager.getProperty("dash.submissions.finalize");
        if(!submissionsFinalize.equals("true")) {
            log.info("Skipping finalization of " + doi + " due to dash.submissions.finalize = " + submissionsFinalize);
            return 200;
        }
        
        try {
            String encodedDOI = URLEncoder.encode(doi, "UTF-8");
            URL url = new URL(dashServer + "/api/datasets/" + encodedDOI);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestProperty("Content-Type", "application/json-patch+json; charset=UTF-8");
            connection.setRequestProperty("Authorization", "Bearer " + oauthToken);
            connection.setDoOutput(true);
            connection.setRequestMethod("PATCH");

            OutputStreamWriter wr = new OutputStreamWriter(connection.getOutputStream());
            wr.write("[{\"op\": \"replace\", \"path\": \"/versionStatus\", " +
                     "\"value\": \"submitted\"}]");
            wr.close();

            InputStream stream = connection.getErrorStream();
            if (stream == null) {
                stream = connection.getInputStream();
            }                                         
            reader = new BufferedReader(new InputStreamReader(stream));
            String line = null;
            StringWriter out = new StringWriter(connection.getContentLength() > 0 ? connection.getContentLength() : 2048);
            while ((line = reader.readLine()) != null) {
                out.append(line);
            }
            String response = out.toString();
            
            responseCode = connection.getResponseCode();

            if(responseCode == 200 || responseCode == 201 || responseCode == 202) {
                log.debug("package submission successful");
            } else {
                log.fatal("Unable to update submission status of item to DASH, response: " +
                          responseCode + connection.getResponseMessage());
            }
            
            log.info("result object " + response);
        } catch (Exception e) {
            log.fatal("Unable to update submission status of item in DASH", e);
        }

        return responseCode;        
    }

    public static void main(String[] args) throws IOException {
        
        String usage = "\n\nUsage: \n" +
            "\tlookup a specific item: dash-service doi\n";
        DashService service = new DashService();

        // LOOKUP: args[0]=DOI
        if (args.length == 1) {
            String doiID = args[0];
            System.out.println(service.getDashJSON(doiID));
        } else {
            System.out.println(usage);
        }
    }


}