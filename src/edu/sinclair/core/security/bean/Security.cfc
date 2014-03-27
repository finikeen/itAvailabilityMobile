<!--- 

 --->
<cfcomponent displayname="Security" hint="Security object">

	<!---
	<cfproperty name="inst" type="any" required="0" displayname="inst" hint="Instance Var to Match Flex" default="">
	--->
	<cfproperty name="loggedin" type="numeric" required="1" displayname="loggedin" hint="Log In Status" default="0">
	<cfproperty name="networkUserID" type="string" required="0" displayname="networkUserID" hint="Network User ID" default="">
	<cfproperty name="user" type="string" required="1" displayname="user" hint="User" default="">
	<cfproperty name="fName" type="string" required="0" displayname="fName" hint="First Name" default="">
	<cfproperty name="lName" type="string" required="0" displayname="lName" hint="Last Name" default="">
	<cfproperty name="tartanID" type="numeric" required="1" displayname="tartanID" hint="Unique User ID" default="0">
	<cfproperty name="email" type="string" required="0" displayname="email" hint="Email" default="">
	<cfproperty name="pass" type="string" required="0" displayname="pass" hint="Password" default="">
	<cfproperty name="client" type="any" required="0" displayname="client" hint="Client object" default="">
	<cfproperty name="currrole" type="string" required="0" displayname="currrole" hint="Current Role" default="Guest">
	<cfproperty name="isEditor" type="boolean" required="0" displayname="isEditor" hint="If a user has editor priviledges." default="0">
	<cfproperty name="securityState" type="string" required="0" displayname="securityState" hint="Security State" default="">
	<cfproperty name="errorMessage" type="string" required="0" displayname="errorMessage" hint="Error Message" default="">

	<cfscript>
		//default values:
		variables.instance.loggedin = 0;
		variables.instance.networkUserID = "";
		variables.instance.user = "";
		variables.instance.fname = "";
		variables.instance.lname = "";
		variables.instance.tartanid = 0;
		variables.instance.email = "";
		variables.instance.pass = "";
		variables.instance.client = "";
		variables.instance.currrole = "Guest";
	</cfscript>

	<!--- 
	***********************
	**  INIT
	***********************
	--->
	<cffunction name="init" access="public" returntype="Security" output="false" displayname="Security Constructor" hint="I initialize an object of type Security.">
		<cfargument name="loggedIn" type="number" default="0"/>
		<cfargument name="networkUserID" type="string" default=""/>
		<cfargument name="user" type="string" default=""/>
		<cfargument name="fName" type="string" default=""/>
		<cfargument name="lName" type="string" default=""/>
		<cfargument name="tartanID" type="number" default="0"/>
		<cfargument name="email" type="string" default=""/>
		<cfargument name="pass" type="string" default=""/>
		<cfargument name="client" type="any" default=""/>
		<cfargument name="currrole" type="string" default="Guest"/>

		<cfscript>
			setLoggedIn(arguments.loggedIn);
			setNetworkUserID(arguments.networkUserID);
			setUser(arguments.user);
			setFName(arguments.fName);
			setLName(arguments.lName);
			setTartanID(arguments.tartanID);
			setEmail(arguments.email);
			setPass(arguments.pass);
			setClient(arguments.client);
			setCurrrole(arguments.currrole);

			return this;
		</cfscript>
	</cffunction>


	<!--- 
	***********************
	**  METHODS
	***********************
	--->


	<!--- 
	***********************
	**  GETTERS and SETTERS
	***********************
	--->	

	<cffunction name="getLoggedIn" access="public" returnType="numeric" output="FALSE">
		<cfreturn variables.instance.loggedIn>
	</cffunction>
	<cffunction name="setLoggedIn" access="public" output="FALSE">
		<cfargument name="loggedIn" type="numeric" required="1"/>
		<cfset variables.instance.loggedIn = arguments.loggedIn>
	</cffunction>

	<cffunction name="getNetworkUserID" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.networkUserID>
	</cffunction>
	<cffunction name="setNetworkUserID" access="public" output="FALSE">
		<cfargument name="networkUserID" type="string" required="1" />
		<cfset variables.instance.networkUserID = arguments.networkUserID>
	</cffunction>

	<cffunction name="getUser" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.user>
	</cffunction>
	<cffunction name="setUser" access="public" output="FALSE">
		<cfargument name="user" type="string" required="1"/>
		<cfset variables.instance.user = arguments.user>
	</cffunction>

	<cffunction name="getFName" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.fName>
	</cffunction>
	<cffunction name="setFName" access="public" output="FALSE">
		<cfargument name="fName" type="string" required="1"/>
		<cfset variables.instance.fName = arguments.fName>
	</cffunction>

	<cffunction name="getLName" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.lName>
	</cffunction>
	<cffunction name="setLName" access="public" output="FALSE">
		<cfargument name="lName" type="string" required="1"/>
		<cfset variables.instance.lName = arguments.lName>
	</cffunction>

	<cffunction name="getTartanID" access="public" returnType="numeric" output="FALSE">
		<cfreturn variables.instance.tartanID>
	</cffunction>
	<cffunction name="setTartanID" access="public" output="FALSE">
		<cfargument name="tartanID" type="numeric" required="1" />
		<cfset variables.instance.tartanID = arguments.tartanID>
	</cffunction>

	<cffunction name="getEmail" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.email>
	</cffunction>
	<cffunction name="setEmail" access="public" output="FALSE">
		<cfargument name="email" type="string" required="1"/>
		<cfset variables.instance.email = arguments.email>
	</cffunction>
	
	<cffunction name="getPass" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.pass>
	</cffunction>
	<cffunction name="setPass" access="public" output="FALSE">
		<cfargument name="pass" type="string" required="1"/>
		<cfset variables.instance.pass = arguments.pass>
	</cffunction>
	
	<cffunction name="getClient" access="public" returnType="any" output="FALSE">
		<cfreturn variables.instance.client>
	</cffunction>
	<cffunction name="setClient" access="public" output="FALSE">
		<cfargument name="client" type="any" required="1"/>
		<cfset variables.instance.client = arguments.client>
	</cffunction>
	
	<cffunction name="getCurrrole" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.currrole>
	</cffunction>
	<cffunction name="setCurrrole" access="public" output="FALSE">
		<cfargument name="currrole" type="string" required="0"/>
		<cfset variables.instance.currrole = arguments.currrole>
	</cffunction>
	

</cfcomponent>
