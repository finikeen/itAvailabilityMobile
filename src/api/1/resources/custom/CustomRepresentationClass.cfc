<cfcomponent extends="taffy.core.baseRepresentation">

    <cfset variables.AnythingToXML = Application.beanFactory.getBean('AnythingToXML') />
    <cfset variables.JSONUtil = Application.beanFactory.getBean('JSONUtil') />

	<cffunction name="getAsJSON" taffy:mime="application/json" taffy:default="true" output="false">
		<cfreturn variables.JSONUtil.serializeJson(variables.data) />
	</cffunction>
	
	<cffunction name="getAsXML" taffy:mime="application/xml" output="false">
		<cfreturn variables.AnythingToXML.ToXML(variables.data) />
	</cffunction>
</cfcomponent>