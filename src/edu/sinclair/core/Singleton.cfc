<cfcomponent displayname="singleton">
   
   <cffunction name="getInstance" access="public" output="false">   
      <cfset var displayname = getMetaData(this).displayname>
      
      <cfif not isdefined("request.#displayname#")>
         <cfset request[displayname] = this>
      </cfif>   
      
      <cfreturn request[displayname]>
   </cffunction>

</cfcomponent>