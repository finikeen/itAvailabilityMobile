<cfcomponent displayName="FilterCollection" hint="Filter information for Flexicious Grids.">

	<cfproperty name="pageSize" type="numeric" required="0" displayname="pageSize" hint="" default="0">
	<cfproperty name="pageIndex" type="numeric" required="0" displayname="pageIndex" hint="" default="0">
	<cfproperty name="pageCount" type="numeric" required="0" displayname="pageCount" hint="" default="0">
	<cfproperty name="recordCount" type="numeric" required="0" displayname="recordCount" hint="" default="0">
	<cfproperty name="recordType" type="string" required="0" displayname="recordType" hint="" default="">
	<cfproperty name="records" type="struct" required="0" displayname="records" hint="" default="structnew()">
	<cfproperty name="arguments" type="array" required="0" displayname="arguments" hint="An array collection for the filter expressions." default="arraynew(1)">
	<cfproperty name="sorts" type="array" required="0" displayname="sorts" hint="The sort order and fields for the filters." default="arraynew(1)">
	<cfproperty name="strFilter" type="string" required="0" displayname="strFilter" hint="The filter string that can be built from the arguments filter expressions collections." default="">


	<cfscript>
		variables.instance.pageSize = 0;
		variables.instance.pageIndex = 0;
		variables.instance.pageCount = 0;
		variables.instance.recordCount = 0;
		variables.instance.recordType = "";
		variables.instance.records = structnew();
		variables.instance.arguments = arraynew(1);
		variables.instance.sorts = arraynew(1);
		variables.instance.strFilter = "";
	</cfscript>
	
	<!--- init() --->
	<cffunction name="init" access="private" returntype="void" output="false" displayname="Filter Collection Constructor" hint="I initialize an object of type FilterCollection.">
		<cfargument name="pageSize" type="numeric" default="0"/>
		<cfargument name="pageIndex" type="numeric" default="0"/>
		<cfargument name="pageCount" type="numeric" default="0"/>
		<cfargument name="recordCount" type="numeric" default="0"/>
		<cfargument name="recordType" type="string" default=""/>
		<cfargument name="records" type="struct" default="structnew()"/>
		<cfargument name="arrArguments" type="array" default="arraynew(1)"/>
		<cfargument name="sorts" type="array" default="arraynew(1)"/>
		<cfargument name="strFilter" type="string" default=""/>

		<cfscript>
			setPageSize(arguments.pageSize);
			setPageIndex(arguments.pageIndex);	
			setPageCount(arguments.pageCount);	
			setRecordCount(arguments.recordCount);
			setRecordType(arguments.recordType);
			setRecords(arguments.records);
			setArguments(arguments["arrArguments"]);
			setSorts(arguments.sorts);
			setStrFilter(arguments.strFilter);
		</cfscript>
	</cffunction>
	
	
	<!--- 
	***********************
	**  GETTERS and SETTERS
	***********************
	--->
	
	<!--- pageSize --->
	<cffunction name="getPageSize" access="public" returntype="numeric" output="false" hint="I return the pageSize for the filter collection.">
		<cfreturn variables.instance.pageSize />
	</cffunction>
	<cffunction name="setPageSize" access="public" returntype="VOID" output="false" hint="I set the pageSize for the filter collection.">
		<cfargument name="pageSize" type="numeric" required="true" />
		<cfset variables.instance.pageSize = arguments.pageSize />
	</cffunction>
	
	<!--- pageIndex --->
	<cffunction name="getPageIndex" access="public" returntype="numeric" output="false" hint="I return the pageIndex for the filter collection.">
		<cfreturn variables.instance.pageIndex />
	</cffunction>
	<cffunction name="setPageIndex" access="public" returntype="VOID" output="false" hint="I set the pageIndex for the filter collection.">
		<cfargument name="pageIndex" type="numeric" required="true" />
		<cfset variables.instance.pageIndex = arguments.pageIndex />
	</cffunction>		

	<!--- pageCount --->
	<cffunction name="getPageCount" access="public" returntype="numeric" output="false" hint="I return the pageCount for the filter collection.">
		<cfreturn variables.instance.pageCount />
	</cffunction>
	<cffunction name="setPageCount" access="public" returntype="VOID" output="false" hint="I set the pageCount for the filter collection.">
		<cfargument name="pageCount" type="numeric" required="true" />
		<cfset variables.instance.pageCount = arguments.pageCount />
	</cffunction>	

	<!--- recordCount --->
	<cffunction name="getRecordCount" access="public" returntype="numeric" output="false" hint="I return the recordCount for the filter collection.">
		<cfreturn variables.instance.recordCount />
	</cffunction>
	<cffunction name="setRecordCount" access="public" returntype="VOID" output="false" hint="I set the recordCount for the filter collection.">
		<cfargument name="recordCount" type="numeric" required="true" />
		<cfset variables.instance.recordCount = arguments.recordCount />
	</cffunction>	

	<!--- recordType --->
	<cffunction name="getRecordType" access="public" returntype="string" output="false" hint="I return the recordType for the filter collection.">
		<cfreturn variables.instance.recordType />
	</cffunction>
	<cffunction name="setRecordType" access="public" returntype="VOID" output="false" hint="I set the recordType for the filter collection.">
		<cfargument name="recordType" type="string" required="true" />
		<cfset variables.instance.recordType = arguments.recordType />
	</cffunction>

	<!--- records --->
	<cffunction name="getRecords" access="public" returntype="struct" output="false" hint="I return the records for the filter collection.">
		<cfreturn variables.instance.records />
	</cffunction>
	<cffunction name="setRecords" access="public" returntype="VOID" output="false" hint="I set the records for the filter collection.">
		<cfargument name="records" type="struct" required="true" />
		<cfset variables.instance.records = arguments.records />
	</cffunction>

	<!--- arguments --->
	<cffunction name="getArguments" access="public" returntype="array" output="false" hint="I return the arguments/expressions collection for the filter collection.">
		<cfreturn variables.instance.arguments />
	</cffunction>
	<cffunction name="setArguments" access="public" returntype="VOID" output="false" hint="I set the arguments/expressions collection for the filter collection.">
		<cfargument name="arrArguments" type="array" required="true" />
		<cfset variables.instance.arguments = arguments["arrArguments"] />
	</cffunction>
	<cffunction name="addFilterExpression" access="public" returntype="VOID" output="false" hint="I add a filter expression to the expressions collection for the filter collection.">
		<cfargument name="expression" type="any" required="true" />
		<cfset ArrayAppend(variables.instance.arguments,arguments.expression) />
	</cffunction>
	
	<!--- sorts --->
	<cffunction name="getSorts" access="public" returntype="array" output="false" hint="I return the sorts for the filter collection.">
		<cfreturn variables.instance.sorts />
	</cffunction>
	<cffunction name="setSorts" access="public" returntype="VOID" output="false" hint="I set the sorts for the filter collection.">
		<cfargument name="sorts" type="array" required="true" />
		<cfset variables.instance.sorts = arguments.sorts />
	</cffunction>
	<cffunction name="addSort" access="public" returntype="VOID" output="false" hint="I add a sort to the filter collection.">
		<cfargument name="sort" type="struct" required="true" />
		<cfset ArrayAppend(variables.instance.sorts,arguments.sort) />
	</cffunction>
	
	<!--- filter --->
	<cffunction name="getStrFilter" access="public" returntype="string" output="false" hint="I return the filter string for the filter collection.">
		<cfreturn variables.instance.strFilter />
	</cffunction>
	<cffunction name="setStrFilter" access="public" returntype="VOID" output="false" hint="I set the filter string for the filter collection.">
		<cfargument name="strFilter" type="string" required="true" />
		<cfset variables.instance.strFilter = arguments.strFilter />
	</cffunction>
	
	<!--- 
	translateApiFilterSettings()
	** Used to translate an expressions object string from a REST url into an Object usable for ColdFusion ORM.
	** Ie. create an appropriate filter and sort objects for Hibernate.
	--->
	<cffunction name="translateApiFilterSettings" access="public" returntype="void" output="false" hint="I set the filter properties for the filter collection.">
		<cfargument name="strFilter" type="string" required="true" />
		
		<cfscript>
			strFilterProps = StructNew();
			strFilter = arguments.strFilter;
			setPageIndex( ListGetAt(strFilter,1,"@") );
			setPageSize( ListGetAt(strFilter,2,"@") );
		</cfscript>		
		<cfreturn />
	</cffunction>	
		
	<!--- 
	translateFilter()
	** Used to translate a flexicious filter expressions object into one usable for ColdFusion ORM.
	** Ie. create an appropriate filter and sort objects for Hibernate.
	--->
	<cffunction name="translateFilter" access="public" returntype="struct" output="false" hint="I set the filter properties for the filter collection.">
		<cfargument name="filterToTranslate" type="any" required="true" />
		
		<cfscript>
			strFilterProps = StructNew();
			currFilter = arguments.filterToTranslate;
			strFilterProps.filter = buildFilter(currFilter);
			strFilterProps.sortOrder = buildFilterSort(currFilter);
			if (currFilter.getPageIndex() eq 0)
			{
				strFilterProps.startIndex = currFilter.getPageIndex();
			}else{
				strFilterProps.startIndex = (currFilter.getPageIndex()*currFilter.getPageSize());
			}
			strFilterProps.numItems = currFilter.getPageSize();
		</cfscript>		

		<cfreturn strFilterProps />
	</cffunction>

	<!--- 
	buildFilter() 
	--->
	<cffunction name="buildFilter" access="public" returntype="struct" output="false">
		<cfargument name="filterCollection" type="any" required="yes">
		
		<cfscript>
			filterCollection = arguments.filterCollection;		
			
			strFilter = StructNew();
			
			filter = "";
			arrFilters = filterCollection.getArguments();
			for (i=1; i lte ArrayLen(arrFilters); i=i+1)
			{
				arg = arrFilters[i];
				columnName = arg["columnName"];
				filterOperation = arg["filterOperation"];
				expression = arg["expression"];
				
				// Add the column and expression(value) to the filter struct
				strFilter[columnName] = expression;
				
				/*
				if (i gt 1)
				{
					filter = filter & " AND ";
				}
				if (columnName eq "ReportedByFullName")
				{
					filter = filter; // & "(DowntimeEvent.[ReportedBy] IN (SELECT u.networkUserID FROM " & REQUEST.linkedSecurityServerPath & REQUEST.linkedSecurityDBName & "UserInfo u(NOLOCK) WHERE u.fullName like '%" & expression & "%'))";
				}else{
					filter = filter & "(DowntimeEvent.[" & columnName & "]";
			
					switch (filterOperation.toLowerCase())
					{
						case 'between':
							filter = filter & " " & filterOperation & '#CreateODBCDateTime(expression[1])#' & " AND " & '#CreateODBCDateTime(expression[2])#' & ")";
							break;
							
						case 'contains':
							filter = filter & " like '%" & expression & "%')";
							break;
	
						case 'equals':
							filter = filter & " = '" & expression & "')";
							break;	
					}
				}
				*/
			}
			
			return strFilter;
		</cfscript>
	</cffunction>

	<!--- 
	buildFilterSort() 
	--->
	<cffunction name="buildFilterSort" access="public" returntype="string" output="false">
		<cfargument name="filterCollection" type="struct" required="yes">
		
		<cfscript>
			filterCollection = arguments.filterCollection;		
			filterSort = "";
			arrSorts = filterCollection.getSorts();
			for (i=1; i lte ArrayLen(arrSorts); i=i+1)
			{
				arg = arrSorts[i];
				sortColumn = arg["sortColumn"];
				isAscending = arg["isAscending"];
				sortDirection = " asc";
				if (isAscending eq false)
					sortDirection = " desc";	
				
				if (i gt 1)
				{
					filterSort = filterSort & ", ";
				}
				
				// Append column
				filterSort = filterSort & sortColumn;
				
				// Append sortDirection
				filterSort = filterSort & sortDirection;
				
				/*
				if (sortColumn eq "ServiceCategoryDescription")
				{
					filterSort = filterSort & "[ServiceCategory].ServiceCategoryID";
				}else{
					filterSort = filterSort & "[Service]." & sortColumn;
				}
				*/
			}
			
			return filterSort;
		</cfscript>
	</cffunction>

</cfcomponent>