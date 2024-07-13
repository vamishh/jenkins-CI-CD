FROM tomcat:9.0.65-jdk11-openjdk

# Set the working directory to the Tomcat webapps directory
WORKDIR /usr/local/tomcat/webapps

# Copy the WAR file to the webapps directory
COPY target/WebApp.war .

# Remove the existing ROOT application and rename the WAR file to ROOT.war
RUN rm -rf ROOT && mv WebApp.war ROOT.war

# Use the Catalina script to run Tomcat
ENTRYPOINT ["catalina.sh", "run"]
