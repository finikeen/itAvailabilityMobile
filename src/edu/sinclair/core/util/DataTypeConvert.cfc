<!---
* --------------------------------------------------------------------------------
*
*        Application: newsight DataTypeConvert Component
*          File Name: DataTypeConvert.cfc
* CFC Component Name: DataTypeConvert
*            Support: ColdFusion MX 6.0, ColdFusion MX 6.1, ColdFusion MX 7
*         Created By: Artur Kordowski - info@newsight.de
*            Created: 02.06.2005
*        Description: A collection of functions to convert a specific data type into another.
*
*    Version History: [dd.mm.yyyy]   [Version]   [Author]        [Comments]
*                      02.06.2005     1.0         A. Kordowski    Created component.
*                      07.06.2005     1.1         A. Kordowski    Add to QueryToStruct() function the argument primaryKey. Optimise
*                                                                 the function to convert the query to two-dimensional struct only.
*                      07.06.2005     1.1.1       A. Kordowski    Fixed bug at the CsvOptRow() function.
*                      17.06.2005     1.1.2       A. Kordowski    Fixed bug at the XmlToQuery() function. Optimize CsvHeader() function
*                                                                 to replace all special characters.
*                      20.06.2005     1.1.3       A. Kordowski    Fixed bug at the XmlToQuery() function.
*
*           Comments: [dd.mm.yyyy]   [Version]   [Author]        [Comments]
*                      03.06.2005     1.0         A. Kordowski    Component tested with ColdFusion MX 7 on Windows XP Professional.
*                      06.06.2005     1.0         A. Kordowski    Created documentation.
*                      07.06.2005     1.0         A. Kordowski    Release component.
*                      07.06.2005     1.1         A. Kordowski    Release component version 1.1. Update documentation.
*
*               Docs: http://livedocs.newsight.de/com/DataTypeConvert/
*
*             Notice: For comments, bug reports or suggestions to optimise this component, feel free to send
*                     a E-Mail: info@newsight.de.
*
*            License: THIS IS A OPEN SOURCE COMPONENT. YOU ARE FREE TO USE THIS COMPONENT IN ANY APPLICATION,
*                     TO COPY IT OR MODIFY THE FUNCTIONS FOR YOUR OWN NEEDS, AS LONG THIS HEADER INFORMATION
*                     REMAINS IN TACT AND YOU DON'T CHARGE ANY MONEY FOR IT. USE THIS COMPONENT AT YOUR OWN
*                     RISK. NO WARRANTY IS EXPRESSED OR IMPLIED, AND NO LIABILITY ASSUMED FOR THE RESULT OF
*                     USING THIS COMPONENT.
*
* --------------------------------------------------------------------------------
--->

<cfcomponent displayname = "DataTypeConvert Component"
             hint        = "A collection of functions to convert a specific data type into another.">

    <cfscript>
        this.breaks = Chr(13) & Chr(10);
        this.tab    = Chr(9);
        this.os     = Server.OS.Name;
    </cfscript>


<!----                                      --->
<!---- BEGIN METHODS ADDED BY SHAWN GORMLEY --->    
<!----                                      --->


<!---
    * returns a query of from xml
    *  
    *
    --->    
    <cffunction name="xmlObjToQuery" access="remote" returntype="query">
        <cfargument name="xmlDoc" type="any" required="true" hint="an xml object">  
        <cfargument name="searchString" type="string" required="true" hint="string representation of XPath to retrieve nodes in the returned query">

            <cfscript>
                arrNodes = XmlSearch(arguments.xmlDoc,arguments.searchString);
                arrStructures = xmlToArrayOfStructures(arrNodes);
                qResult = arrayOfStructuresToQuery(arrStructures);              
            </cfscript>

        <cfreturn qResult>
    </cffunction>

<!---
    * turns an array of xml elements into an array of structures
    *  
    *
    --->    
    <cffunction name="xmlToArrayOfStructures" access="remote" returntype="array">
        <cfargument name="nodes" type="array" required="true" hint=" array of xml nodes to convert to array of structures"> 
            
            <cfscript>  
                var arrNodes = arguments.nodes;
                //var dcObj = CreateObject("Component",request.dataTypeConvertComponentPath);
                len = arraylen(arrNodes);
                for (i = 1; i lte len; i=i+1)
                {
                    strRow = StructNew();
                    strRow = XMLToStruct(arrNodes[i]);
                    arrNodes[i] = strRow[1];
                }
            </cfscript>
    
        <cfreturn arrNodes>
    </cffunction>


<!---
    * turns an array of structures into a query
    *  
    *
    --->    
    <cffunction name="arrayOfStructuresToQuery" access="remote" returntype="query">
        <cfargument name="arrStructures" type="array" required="true" hint="array of structures to convert into a query">   
            
            <cfscript>  
                // setup the array of structures
                arrStructures = arguments.arrStructures;
                str = StructNew();
                numRecords = ArrayLen(arrStructures);
                if (numRecords gt 0)
                {
                    // determine the columns in the query
                    str = arrStructures[1];
                    columnList = StructKeyList(str);
                }else{
                    columnList = "NoRecord"; 
                }
            </cfscript>
    
            <!--- create the query --->
            <cfset rs_arrStructures = QueryNew(columnList)>
            <cfif numRecords gt 0>
                <!--- loop over the array --->
                <cfloop from="1" to="#ArrayLen(arrStructures)#" index="i">
                    <cfset newRow = QueryAddRow(rs_arrStructures, 1)>
                    <cfset strRowData = StructNew()>
                    <cfset strRowData = arrStructures[i]>
                    <cfloop collection="#strRowData#" item="key">
                        <cfset temp = QuerySetCell(rs_arrStructures, key, strRowData[key], i)>
                    </cfloop>
                </cfloop>
            </cfif>
        
        <cfreturn rs_arrStructures>
    </cffunction>


<!--- turn a query result into an array of structures --->
    <cffunction name="queryToArrayOfStructures" access="remote" returntype="array">
        <cfargument name="qToModify" type="query" required="yes">
        <cfargument name="aTemp" type="array" required="yes">
        
        <cfset var qObj = arguments.qToModify>
		<cfset var arrResult = arguments.aTemp>
		<cfset var arrLength = arraylen(arguments.aTemp)>
        <cfset var strTemp = "">
        <!--- use metadata to maintain case from original query --->
        <cfset var arrColNames =  qObj.getMetaData().getColumnLabels()>
        <cfset var lstCols = ArrayToList(arrColNames, ",")>
		<cfset var count = ListLen(lstCols)>
		<cfset var i = 1>
		<cfset var value = "">
		<cfset var key = "">
		<cfset var temp = "">
        
        <!--- <cfdump var="#lstCols#"> --->
         
        <!--- loop over the query and turn each column into a structKey --->
        <cfloop query="qObj">
            <cfset strTemp = StructNew()>
            <!--- loop over each columnName and add a value to each key
                create a new structure for each outer loop --->
            <cfloop from="1" to="#count#" index="i">
                <cfset value = "qObj." & ListGetAt(lstCols,i)>
                <cfset value = Trim( Evaluate(value) )>
                <cfset key = ListGetAt(lstCols,i)>
				<cfset temp = StructInsert(strTemp,key,value)>
            </cfloop>
            <cfset cRow = (qObj.CURRENTROW + arrLength)>
            <!--- set each index in an the array to the id in the structure --->
            <!--- use this method to ensure items are returned in a proper ordered array --->
            <cfset arrResult[cRow] = strTemp>
        </cfloop>

        <!---
        <cfset aTemp = arrResult>
        --->
        
        <cfreturn arrResult>
    </cffunction>


<!----                                    --->
<!---- END METHODS ADDED BY SHAWN GORMLEY --->  
<!----                                    --->


    <!--- -------------------------------------------------- --->
    <!--- ArrayToCsv --->
    <cffunction name="ArrayToCsv" access="public" output="no" returntype="string" hint="Converts a one or two-dimensional array to CSV.">

        <!--- Function Arguments --->
        <cfargument name="array"     required="yes" type="array"                                        hint="The array to convert.">
        <cfargument name="action"    required="no"  type="string" default="return"                      hint="Return or write the CSV string in a file.">
        <cfargument name="delimiter" required="no"  type="string" default=";"                           hint="Character(s) that delimited the fileds.">
        <cfargument name="enclosed"  required="no"  type="string" default=""""                          hint="Character(s) that enclosed the field.">
        <cfargument name="empty"     required="no"  type="string" default=""                            hint="String that replace a empty field.">
        <cfargument name="file"      required="no"  type="string" default="#ExpandPath(".")#\array.csv" hint="Pathname of the CSV file to write.">
        <cfargument name="charset"   required="no"  type="string" default="ISO-8859-1"                  hint="The character encoding in which the CSV file contents is encoded.">

        <cfscript>

            /* Default variables */
            var csv = "";

            /* One or two-dimensional array */
            if(IsArray(arguments.array, 1) OR IsArray(arguments.array, 2))
            {
                // Create CSV string
                query = ArrayToQuery(arguments.array);
                csv   = QueryToCsv(query     = query,
                                   delimiter = arguments.delimiter,
                                   enclosed  = arguments.enclosed,
                                   empty     = arguments.empty);
            }

            /* Return false if array is three-dimensional */
            else
                return false;

            /* Return or write the CSV string in a file. */
            switch(arguments.action)
            {
                case "return": return csv; break;
                case "write":  WriteToFile(arguments.file, Trim(csv), arguments.charset); break;
            }

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- ArrayToQuery --->
    <cffunction name="ArrayToQuery" access="public" output="no" hint="Converts a one or two-dimensional array to query.">

        <!--- Function Arguments --->
        <cfargument name="array" required="yes" type="array" hint="The array to convert.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var query = QueryNew("");

            /* Convert one-dimensional array */
            if(IsArray(arguments.array, 1))
            {
                QueryAddColumn(query, "column", arguments.array);
                return query;
            }

            /* Convert two-dimensional array */
            else if(IsArray(arguments.array, 2))
            {
                for(i=1; i LTE ArrayLen(arguments.array); i=i+1)
                {
                    if(ArrayKeyExists(arguments.array, i) EQ "true" AND NOT ArrayIsEmpty(arguments.array[i]))
                        QueryAddColumn(query, "column_#i#", arguments.array[i]);
                }

                return query;
            }

            /* Return false if array is three-dimensional */
            else if(IsArray(arguments.array, 3))
                return false;

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- ArrayToStruct --->
    <cffunction name="ArrayToStruct" access="public" output="no" returntype="struct" hint="Converts a array to a struct.">

        <!--- Function Arguments --->
        <cfargument name="array" required="yes" type="array" hint="The array to convert.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var struct = StructNew();

            /* Loop over array */
            for(i=1; i LTE ArrayLen(arguments.array); i=i+1)
            {
                if(ArrayKeyExists(arguments.array, i) EQ "true")
                {
                    /* Set array content */
                    if(NOT IsArray(arguments.array[i]))
                        struct[i] = arguments.array[i];

                    /* Get array sub elements */
                    else if(IsArray(arguments.array[i]) AND NOT ArrayIsEmpty(arguments.array[i]))
                        struct[i] = ArrayToStruct(arguments.array[i]);
                }
            }

            /* Return struct */
            return struct;

        </cfscript>

    </cffunction>


    <!--- -------------------------------------------------- --->
    <!--- ArrayToXml --->
    <cffunction name="ArrayToXml" access="public" output="no" returntype="string" hint="Converts a array to XML.">

        <!--- Function Arguments --->
        <cfargument name="array"     required="yes" type="array"                                        hint="The array to convert.">
        <cfargument name="action"    required="no"  type="string" default="return"                      hint="Return or write the XML string in a file.">
        <cfargument name="file"      required="no"  type="string" default="#ExpandPath(".")#\array.xml" hint="Pathname of the XML file to write.">
        <cfargument name="charset"   required="no"  type="string" default="UTF-8"                       hint="The character encoding in which the XML file contents is encoded.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var n = 0;
            var xml     = "";
            var tabs    = "";
            var tabsLen = 0;

            /* Set tabs */
            if(IsDefined("arguments.tab"))
            {
                tabsLen = arguments.tab + 1;

                for(n=1; n LTE tabsLen; n=n+1)
                    tabs = tabs & this.tab;
            }

            /* Create XML struct */
            if(NOT IsDefined("arguments.tab"))
                xml     = '<?xml version="1.0" encoding="#arguments.charset#"?>' & this.breaks;

            xml = xml & tabs & '<array>' & this.breaks;

            /* Loop over array */
            for(i=1; i LTE ArrayLen(arguments.array); i=i+1)
            {
                // Check if array key exists
                if(ArrayKeyExists(arguments.array, i) EQ "true")
                {
                    // Set content
                    if(NOT IsArray(arguments.array[i]))
                    {
                        if(IsNumeric(arguments.array[i])) content = arguments.array[i];
                        else                              content = "<![CDATA[#arguments.array[i]#]]>";

                        xml = xml & tabs & this.tab & '<element>#content#</element>' & this.breaks;
                    }

                    // Get array sub elements
                    else if(IsArray(arguments.array[i]) AND NOT ArrayIsEmpty(arguments.array[i]))
                        xml = xml & ArrayToXml(array=arguments.array[i], tab=tabsLen);
                }
            }

            xml = xml & tabs & '</array>' & this.breaks;

            /* Return or write the XML string in a file. */
            switch(arguments.action)
            {
                case "return": return xml; break;
                case "write":  WriteToFile(arguments.file, Trim(xml), arguments.charset); break;
            }

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- ArrayKeyExists --->
    <cffunction name="ArrayKeyExists" access="public" output="no" returntype="boolean" hint="Determines whether a specific key is present in a array.">

        <!--- Function Arguments --->
        <cfargument name="array" required="yes" type="array"   hint="Array to test.">
        <cfargument name="pos"   required="yes" type="numeric" hint="Array key to test.">

        <cfscript>

            /* Check array key */
            try
            {
                temp = arguments.array[arguments.pos];
                return true;
            }

            /* Return false */
            catch(coldfusion.runtime.UndefinedElementException ex)
            { return false; }

            catch(coldfusion.runtime.CfJspPage$ArrayBoundException ex)
            { return false; }

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- CsvToArray --->
    <cffunction name="CsvToArray" access="public" output="no" returntype="array" hint="Converts a CSV to array.">

        <!--- Function Arguments --->
        <cfargument name="csvString"   required="no" type="string"                          hint="CSV string. Required if argument file is not set.">
        <cfargument name="file"        required="no" type="string"                          hint="Pathname or URL of the CSV file to read. Required if argument csvString is not set.">
        <cfargument name="charset"     required="no" type="string"  default="ISO-8859-1"    hint="The character encoding in which the CSV file contents is encoded.">
        <cfargument name="headerFirst" required="no" type="boolean" default="yes"           hint="Column names at first row.">
        <cfargument name="delimiter"   required="no" type="string"  default=";"             hint="Character(s) that delimited the fileds.">
        <cfargument name="enclosed"    required="no" type="string"  default=""""            hint="Character(s) that enclosed the field.">
        <cfargument name="linefeed"    required="no" type="string"  default="#this.breaks#" hint="Character(s) for the linefeed.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var n = 0;
            var array = ArrayNew(2);

            if(IsDefined("arguments.csvString")) csv = arguments.csvString;
            else                                 csv = ReadFile(arguments.file, arguments.charset);

            /* Remove header */
            if(arguments.headerFirst EQ "yes")
                csv = ListDeleteAt(csv, 1, arguments.linefeed);

            csv = ListToArray(csv, arguments.linefeed);

            /* Loop over rows */
            for(i=1; i LTE ArrayLen(csv); i=i+1)
            {
                col = ListToArray(CsvOptRow(csv[i], arguments.delimiter, arguments.enclosed), arguments.delimiter);

                // Loop over columns
                for(n=1; n LTE ArrayLen(col); n=n+1)
                    array[n][i] = Trim(col[n]);
            }

            /* Return array */
            return array;

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- CsvToQuery --->
    <cffunction name="CsvToQuery" access="public" output="no" returntype="query" hint="Converts a CSV to query.">

        <!--- Function Arguments --->
        <cfargument name="csvString"   required="no" type="string"                          hint="CSV string. Required if argument file is not set.">
        <cfargument name="file"        required="no" type="string"                          hint="Pathname or URL of the CSV file to read. Required if argument csvString is not set.">
        <cfargument name="charset"     required="no" type="string"  default="ISO-8859-1"    hint="The character encoding in which the CSV file contents is encoded.">
        <cfargument name="headerFirst" required="no" type="boolean" default="yes"           hint="Column names at first row.">
        <cfargument name="delimiter"   required="no" type="string"  default=";"             hint="Character(s) that delimited the fileds.">
        <cfargument name="enclosed"    required="no" type="string"  default=""""            hint="Character(s) that enclosed the field.">
        <cfargument name="linefeed"    required="no" type="string"  default="#this.breaks#" hint="Character(s) for the linefeed.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var n = 0;

            if(IsDefined("arguments.csvString")) csv = arguments.csvString;
            else                                 csv = ReadFile(arguments.file, arguments.charset);

            column = CsvHeader(ListFirst(csv, arguments.linefeed), arguments.headerFirst, arguments.delimiter, arguments.enclosed);
            query  = QueryNew(column);

            /* Remove header */
            if(arguments.headerFirst EQ "yes")
                csv = ListDeleteAt(csv, 1, arguments.linefeed);

            csv    = ListToArray(csv, arguments.linefeed);
            column = ListToArray(column);

            QueryAddRow(query, ArrayLen(csv));

            /* Loop over rows */
            for(i=1; i LTE ArrayLen(csv); i=i+1)
            {
                col = ListToArray(CsvOptRow(csv[i], arguments.delimiter, arguments.enclosed), arguments.delimiter);

                // Loop over columns
                for(n=1; n LTE ArrayLen(col); n=n+1)
                    query[column[n]][i] = Trim(col[n]);
            }

            /* Return query */
            return query;

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- CsvToStruct --->
    <cffunction name="CsvToStruct" access="public" output="no" returntype="struct" hint="Converts a CSV to struct.">

        <!--- Function Arguments --->
        <cfargument name="csvString"   required="no" type="string"                          hint="CSV string. Required if argument file is not set.">
        <cfargument name="file"        required="no" type="string"                          hint="Pathname or URL of the CSV file to read. Required if argument csvString is not set.">
        <cfargument name="charset"     required="no" type="string"  default="ISO-8859-1"    hint="The character encoding in which the CSV file contents is encoded.">
        <cfargument name="headerFirst" required="no" type="boolean" default="yes"           hint="Column names at first row.">
        <cfargument name="delimiter"   required="no" type="string"  default=";"             hint="Character(s) that delimited the fileds.">
        <cfargument name="enclosed"    required="no" type="string"  default=""""            hint="Character(s) that enclosed the field.">
        <cfargument name="linefeed"    required="no" type="string"  default="#this.breaks#" hint="Character(s) for the linefeed.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var n = 0;
            var struct = StructNew();

            if(IsDefined("arguments.csvString")) csv = arguments.csvString;
            else                                 csv = ReadFile(arguments.file, arguments.charset);

            column = CsvHeader(ListFirst(csv, arguments.linefeed), arguments.headerFirst, arguments.delimiter, arguments.enclosed);

            /* Remove header */
            if(arguments.headerFirst EQ "yes")
                csv = ListDeleteAt(csv, 1, arguments.linefeed);

            csv    = ListToArray(csv, arguments.linefeed);
            column = ListToArray(column);

            /* Loop over rows */
            for(i=1; i LTE ArrayLen(csv); i=i+1)
            {
                col = ListToArray(CsvOptRow(csv[i], arguments.delimiter, arguments.enclosed), arguments.delimiter);

                // Loop over columns
                for(n=1; n LTE ArrayLen(col); n=n+1)
                    struct[column[n]][i] = Trim(col[n]);
            }

            /* Return struct */
            return struct;

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- CsvToXml --->
    <cffunction name="CsvToXml" access="public" output="no" returntype="string" hint="Converts a CSV to XML.">

        <!--- Function Arguments --->
        <cfargument name="csvString"   required="no" type="string"                                      hint="CSV string. Required if argument file is not set.">
        <cfargument name="file"        required="no" type="string"                                      hint="Pathname or URL of the CSV file to read. Required if argument csvString is not set.">
        <cfargument name="charset"     required="no" type="string"  default="ISO-8859-1"                hint="The character encoding in which the CSV file contents is encoded.">
        <cfargument name="action"      required="no" type="string"  default="return"                    hint="Return or write the XML string in a file.">
        <cfargument name="headerFirst" required="no" type="boolean" default="yes"                       hint="Column names at first row.">
        <cfargument name="delimiter"   required="no" type="string"  default=";"                         hint="Character(s) that delimited the fileds.">
        <cfargument name="enclosed"    required="no" type="string"  default=""""                        hint="Character(s) that enclosed the field.">
        <cfargument name="linefeed"    required="no" type="string"  default="#this.breaks#"             hint="Character(s) for the linefeed.">
        <cfargument name="xmlFile"     required="no" type="string"  default="#ExpandPath(".")#\csv.xml" hint="Pathname of the XML file to write.">
        <cfargument name="xmlCharset"  required="no" type="string"  default="UTF-8"                     hint="The character encoding in which the XML file contents is encoded.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var n = 0;
            var xml = "";

            if(IsDefined("arguments.csvString")) csv = arguments.csvString;
            else                                 csv = ReadFile(arguments.file, arguments.charset);

            column = CsvHeader(ListFirst(csv, arguments.linefeed), arguments.headerFirst, arguments.delimiter, arguments.enclosed);

            /* Remove header */
            if(arguments.headerFirst EQ "yes")
                csv = ListDeleteAt(csv, 1, arguments.linefeed);

            csv    = ListToArray(csv, arguments.linefeed);
            column = ListToArray(LCase(column));

            /* Create XML string */
            xml = xml & '<?xml version="1.0" encoding="#arguments.charset#"?>' & this.breaks;
            xml = xml & '<csv>' & this.breaks;

            /* Loop over rows */
            for(i=1; i LTE ArrayLen(csv); i=i+1)
            {
                col = ListToArray(CsvOptRow(csv[i], arguments.delimiter, arguments.enclosed), arguments.delimiter);

                xml = xml & this.tab & "<row>" & this.breaks;

                for(n=1; n LTE ArrayLen(col); n=n+1)
                {
                    if(IsNumeric(col[n])) content = col[n];
                    else                  content = '<![CDATA[#col[n]#]]>';

                    xml = xml & this.tab & this.tab & '<#column[n]#>#content#</#column[n]#>' & this.breaks;
                }

                xml = xml & this.tab & "</row>" & this.breaks;
            }

            xml = xml & '</csv>';

            /* Return or write the XML data in a file */
            switch(arguments.action)
            {
                case "return": return xml; break;
                case "write":  WriteToFile(arguments.xmlFile, Trim(xml), arguments.xmlCharset); break;
            }

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- ListToQuery --->
    <cffunction name="ListToQuery" access="public" output="no" returntype="query" hint="Converts a list to query.">

        <!--- Function Arguments --->
        <cfargument name="list"      required="yes" type="string"             hint="The list to convert.">
        <cfargument name="delimiter" required="no"  type="string" default="," hint="Character(s) that separate list elements.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var query = QueryNew("list");
            var array = ListToArray(arguments.list, arguments.delimiter);

            /* Add rows to query */
            QueryAddRow(query, ArrayLen(array));

            /* Set data to query row */
            for(i=1; i LTE ArrayLen(array); i=i+1)
                query.list[i] = Trim(array[i]);

            /* Return query */
            return query;

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- ListToStruct --->
    <cffunction name="ListToStruct" access="public" output="no" returntype="struct" hint="Converts a list to struct.">

        <!--- Function Arguments --->
        <cfargument name="list"      required="yes" type="string"             hint="The list to convert.">
        <cfargument name="delimiter" required="no"  type="string" default="," hint="Character(s) that separate list elements.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var struct = StructNew();
            var array  = ListToArray(arguments.list, arguments.delimiter);

            /* Set data to struct */
            for(i=1; i LTE ArrayLen(array); i=i+1)
                struct[i] = Trim(array[i]);

            /* Return struct */
            return struct;

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- ListToXml --->
    <cffunction name="ListToXml" access="public" output="no" returntype="string" hint="Converts a list to XML.">

        <!--- Function Arguments --->
        <cfargument name="list"      required="yes" type="string"                                      hint="The list to convert.">
        <cfargument name="delimiter" required="no"  type="string" default=","                          hint="Character(s) that separate list elements.">
        <cfargument name="action"    required="no"  type="string" default="return"                     hint="Return or write the XML string in a file.">
        <cfargument name="file"      required="no"  type="string" default="#ExpandPath(".")#\list.xml" hint="Pathname of the XML file to write.">
        <cfargument name="charset"   required="no"  type="string" default="UTF-8"                      hint="The character encoding in which the XML file contents is encoded.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var xml   = "";
            var array = ListToArray(arguments.list, arguments.delimiter);

            /* Create XML string */
            xml = '<?xml version="1.0" encoding="#arguments.charset#"?>' & this.breaks;
            xml = xml & '<list>' & this.breaks;

            /* Loop over the list elements */
            for(i=1; i LTE ArrayLen(array); i=i+1)
            {
                if(IsNumeric(array[i])) content = Trim(array[i]);
                else                    content = '<![CDATA[#Trim(array[i])#]]>';

                xml = xml & this.tab & '<element>#content#</element>' & this.breaks;
            }

            xml = xml & '</list>';

            /* Return or write the XML string in a file */
            switch(arguments.action)
            {
                case "return": return xml; break;
                case "write":  WriteToFile(arguments.file, Trim(xml), arguments.charset); break;
            }

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- QueryToArray --->
    <cffunction name="QueryToArray" access="public" output="no" returntype="array" hint="Converts a query to array.">

        <!--- Function Arguments --->
        <cfargument name="query"      required="yes" type="query"  hint="The query to convert.">
        <cfargument name="columnList" required="no"  type="string" hint="Comma-delimited list of the query columns.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var n = 0;
            var cols = "";

            /* Set query column names */
            if(IsDefined("arguments.columnList")) cols = ListToArray(LCase(Replace(arguments.columnList, " ", "")));
            else                                  cols = ListToArray(LCase(arguments.query.columnList));

            /* Create one dimensional array */
            if(ArrayLen(cols) EQ 1)
            {
                array = ArrayNew(1);

                // Loop over rows
                for(i=1; i LTE arguments.query.recordcount; i=i+1)
                    array[i] = arguments.query[cols[1]][i];
            }

            /* Create two dimensional array */
            else
            {
                array = ArrayNew(2);

                // Loop over columns
                for(i=1; i LTE ArrayLen(cols); i=i+1)
                {
                    // Loop over rows
                    for(n=1; n LTE arguments.query.recordcount; n=n+1)
                        array[n][i] = arguments.query[cols[i]][n];
                }
            }

            /* Return array */
            return array;

        </cfscript>

    </cffunction>



    <!--- -------------------------------------------------- --->
    <!--- QueryToCsv --->
    <cffunction name="QueryToCsv" access="public" output="no" returntype="string" hint="Converts a query to CSV.">

        <!--- Function Arguments --->
        <cfargument name="query"       required="yes" type="query"                                         hint="The query to convert.">
        <cfargument name="columnList"  required="no"  type="string"                                        hint="Comma-delimited list of the query columns.">
        <cfargument name="action"      required="no"  type="string"  default="return"                      hint="Return or write the CSV string in a file.">
        <cfargument name="headerFirst" required="no"  type="boolean" default="yes"                         hint="Set column names at first row.">
        <cfargument name="headerList"  required="no"  type="string"                                        hint="Comma-delimited list of the CSV columns names.">
        <cfargument name="delimiter"   required="no"  type="string"  default=";"                           hint="Character(s) that delimited the fileds.">
        <cfargument name="enclosed"    required="no"  type="string"  default=""""                          hint="Character(s) that enclosed the field.">
        <cfargument name="empty"       required="no"  type="string"  default=""                            hint="String that replace a empty field.">
        <cfargument name="file"        required="no"  type="string"  default="#ExpandPath(".")#\query.csv" hint="Pathname of the CSV file to write.">
        <cfargument name="charset"     required="no"  type="string"  default="ISO-8859-1"                  hint="The character encoding in which the CSV file contents is encoded.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var n = 0;
            var h = 0;
            var csv = "";
            var row = "";

            /* Set query column names */
            if(IsDefined("arguments.columnList")) cols = ListToArray(LCase(arguments.columnList));
            else                                  cols = ListToArray(LCase(arguments.query.columnList));

            /* Set column names at first row */
            if(arguments.headerFirst EQ "yes")
            {
                if(IsDefined("arguments.headerList")) headers = ListToArray(arguments.headerList);
                else                                  headers = cols;

                for(h=1; h LTE ArrayLen(headers); h=h+1)
                {
                    row = row & arguments.enclosed & Trim(headers[h]) & arguments.enclosed;

                    if(h LT ArrayLen(headers))
                        row = row & arguments.delimiter;
                }

                csv = row & this.breaks;
                row = "";
            }

            /* Loop over query rows */
            for(i=1; i LTE arguments.query.recordcount; i=i+1)
            {
                /* Loop over query columns */
                for(n=1; n LTE ArrayLen(cols); n=n+1)
                {
                    if(IsString(arguments.query[cols[n]][i]))
                    {
                        if(arguments.query[cols[n]][i] EQ "") content = arguments.empty;
                        else                                  content = arguments.query[cols[n]][i];
                    }

                    else
                        content = "";

                    row = row & arguments.enclosed & content & arguments.enclosed;

                    if(n LT ArrayLen(cols))
                        row = row & arguments.delimiter;
                }

                csv = csv & row & this.breaks;
                row = "";
            }

            /* Return or write the CSV string in a file */
            switch(arguments.action)
            {
                case "return": return csv; break;
                case "write":  WriteToFile(arguments.file, Trim(csv), arguments.charset); break;
            }

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- QueryToStruct --->
    <cffunction name="QueryToStruct" access="public" output="no" returntype="struct" hint="Converts a query to struct.">

        <!--- Function Arguments --->
        <cfargument name="query"      required="yes" type="query"  hint="The query to convert.">
        <cfargument name="primaryKey" required="no"  type="string" hint="Column name that contains the primary key.">
        <cfargument name="columnList" required="no"  type="string" hint="Comma-delimited list of the query columns.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var n = 0;
            var cols   = "";
            var struct = StructNew();

            /* Set query column names */
            if(IsDefined("arguments.columnList")) cols = Replace(arguments.columnList, " ", "");
            else                                  cols = arguments.query.ColumnList;

            /* Remove the primary key */
            if(IsDefined("arguments.primaryKey") AND ListFindNoCase(cols, arguments.primaryKey) GT 0)
                cols = ListDeleteAt(cols, ListFindNoCase(cols, arguments.primaryKey));

            cols = ListToArray(LCase(cols));

            /* Loop over rows */
            for(i=1; i LTE arguments.query.recordcount; i=i+1)
            {
                // Set struct key
                if(IsDefined("arguments.primaryKey")) key = arguments.query[arguments.primaryKey][i];
                else                                  key = i;

                // Create a sub struct
                struct[key] = StructNew();

                // Loop over columns
                for(n=1; n LTE ArrayLen(cols); n=n+1)
                    struct[key][cols[n]] = arguments.query[cols[n]][i];
            }

            /* Return struct */
            return struct;

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- QueryToXml --->
    <cffunction name="QueryToXml" access="public" output="no" returntype="any" hint="Converts a query to XML.">

        <!--- Function Arguments --->
        <cfargument name="query"      required="yes" type="query"                                        hint="The query to convert.">
        <cfargument name="columnList" required="no"  type="string"                                       hint="Comma-delimited list of the query columns.">
        <cfargument name="action"     required="no"  type="string" default="return"                      hint="Return or write the XML string in a file.">
        <cfargument name="file"       required="no"  type="string" default="#ExpandPath(".")#\query.xml" hint="Pathname of the XML file to write.">
        <cfargument name="charset"    required="no"  type="string" default="UTF-8"                       hint="The character encoding in which the XML file contents is encoded.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var n = 0;
            var xml  = "";
            var cols = "";

            /* Set query column names */
            if(IsDefined("arguments.columnList")) cols = ListToArray(LCase(Replace(arguments.columnList, " ", "")));
            else                                  cols = ListToArray(LCase(arguments.query.columnList));

            /* Create XML string */
            xml = xml & '<?xml version="1.0" encoding="#arguments.charset#"?>' & this.breaks;
            xml = xml & '<query>' & this.breaks;

            /* Loop over query rows */
            for(i=1; i LTE arguments.query.recordcount; i=i+1)
            {
                xml = xml & this.tab & '<row>' & this.breaks;

                // Loop over query columns
                for(n=1; n LTE ArrayLen(cols); n=n+1)
                {
                    if(IsNumeric(arguments.query[cols[n]][i])) content = arguments.query[cols[n]][i];
                    else                                       content = '<![CDATA[#arguments.query[cols[n]][i]#]]>';

                    xml = xml & this.tab & this.tab & '<#cols[n]#>#content#</#cols[n]#>' & this.breaks;
                }

                xml = xml & this.tab & '</row>' & this.breaks;
            }

            xml = xml & '</query>';

            /* Return or write the XML string in a file */
            switch(arguments.action)
            {
                case "return": return xml; break;
                case "write":  WriteToFile(arguments.file, Trim(xml), arguments.charset); break;
            }

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- StructToArray --->
    <cffunction name="StructToArray" access="public" output="no" returntype="array" hint="Converts a struct to array.">

        <!--- Function Arguments --->
        <cfargument name="struct" required="yes" type="struct" hint="The struct to convert.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var key   = StructKeyArray(arguments.struct);
            var array = ArrayNew(1);

            /* Loop over struct elements */
            for(i=1; i LTE ArrayLen(key); i=i+1)
                array[i] = arguments.struct[key[i]];

            /* Return array */
            return array;

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- StructToCsv --->
    <cffunction name="StructToCsv" access="public" output="no" returntype="string" hint="Converts a struct to CSV.">

        <!--- Function Arguments --->
        <cfargument name="struct"      required="yes" type="struct"                                         hint="The struct to convert.">
        <cfargument name="action"      required="no"  type="string"  default="return"                       hint="Return or write the CSV string in a file.">
        <cfargument name="headerFirst" required="no"  type="boolean" default="yes"                          hint="Set column names at first row.">
        <cfargument name="delimiter"   required="no"  type="string"  default=";"                            hint="Character(s) that delimited the fileds.">
        <cfargument name="enclosed"    required="no"  type="string"  default=""""                           hint="Character(s) that enclosed the field.">
        <cfargument name="empty"       required="no"  type="string"  default=""                             hint="String that replace a empty field.">
        <cfargument name="file"        required="no"  type="string"  default="#ExpandPath(".")#\struct.csv" hint="Pathname of the CSV file to write.">
        <cfargument name="charset"     required="no"  type="string"  default="ISO-8859-1"                   hint="The character encoding in which the CSV file contents is encoded.">

        <cfscript>

            /* Default variables */
            var query = "";
            var csv   = "";

            /* Create CSV string */
            query = StructToQuery(arguments.struct);
            csv   = QueryToCsv(query       = query,
                               headerFirst = arguments.headerFirst,
                               delimiter   = arguments.delimiter,
                               enclosed    = arguments.enclosed,
                               empty       = arguments.empty);

            /* Return or write the CSV string in a file */
            switch(arguments.action)
            {
                case "return": return csv; break;
                case "write":  WriteToFile(arguments.file, Trim(csv), arguments.charset); break;
            }

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- StructToList --->
    <cffunction name="StructToList" access="public" output="no" returntype="string" hint="Converts a struct to list.">

        <!--- Function Arguments --->
        <cfargument name="struct"    required="yes" type="struct"             hint="The struct to convert.">
        <cfargument name="delimiter" required="no"  type="string" default="," hint="Character(s) that separate list elements.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var key  = StructKeyArray(arguments.struct);
            var list = "";

            /* Loop over struct elements */
            for(i=1; i LTE ArrayLen(key); i=i+1)
                list = ListAppend(list, arguments.struct[key[i]], arguments.delimiter);

            /* Return list */
            return list;

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- StructToQuery --->
    <cffunction name="StructToQuery" access="public" output="no" returntype="query" hint="Converts a struct to query.">

        <!--- Function Arguments --->
        <cfargument name="struct" required="yes" type="struct" hint="The struct to convert.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var n = 0;
            var key   = StructKeyArray(arguments.struct);
            var query = QueryNew("");
            var array = ArrayNew(1);

            /* Loop over struct elements */
            for(i=1; i LTE ArrayLen(key); i=i+1)
            {
                if(IsNumeric(key[i])) colName = "col_#key[i]#";
                else                  colName = key[i];

                QueryAddColumn(query, colName, array);
                element = arguments.struct[key[i]];

                // One-dimensional struct
                if(NOT IsStruct(element))
                {
                    if(query.recordcount EQ 0) QueryAddRow(query);
                    QuerySetCell(query, colName, element, query.recordcount);
                }

                // Two-dimensional struct
                else
                {
                    rows = StructKeyArray(element);

                    // Loop over struct subelements
                    for(n=1; n LTE ArrayLen(rows); n=n+1)
                    {
                        if(query.recordcount LT n) QueryAddRow(query);
                        QuerySetCell(query, colName, element[rows[n]], n);
                    }
                }
            }

            /* Return query */
            return query;

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- StructToXml --->
    <cffunction name="StructToXml" access="public" output="yes" returntype="string" hint="Converts a struct to XML.">

        <!--- Function Arguments --->
        <cfargument name="struct"      required="yes" type="struct"                                         hint="The struct to convert.">
        <cfargument name="action"      required="no"  type="string"  default="return"                       hint="Return or write the XML string in a file.">
        <cfargument name="file"        required="no"  type="string"  default="#ExpandPath(".")#\struct.xml" hint="Pathname of the XML file to write.">
        <cfargument name="charset"     required="no"  type="string"  default="UTF-8"                        hint="The character encoding in which the XML file contents is encoded.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var n = 0;
            var key     = StructKeyArray(arguments.struct);
            var xml     = "";
            var name    = "";
            var tabs    = "";
            var tabsLen = 0;

            /* Set tabs */
            if(IsDefined("arguments.tab"))
            {
                tabsLen = arguments.tab + 1;

                for(n=1; n LTE tabsLen; n=n+1)
                    tabs = tabs & this.tab;
            }

            /* Create XML struct */
            if(NOT IsDefined("arguments.tab"))
            {
                xml = '<?xml version="1.0" encoding="#arguments.charset#"?>' & this.breaks;
                xml = xml & '<struct>' & this.breaks;
            }

            /* Loop over struct */
            for(i=1; i LTE ArrayLen(key); i=i+1)
            {
                if(IsNumeric(key[i])) name = "element_#key[i]#";
                else                  name = key[i];

                // Set content
                if(NOT IsStruct(arguments.struct[key[i]]) AND IsString(arguments.struct[key[i]]))
                {
                    if(IsNumeric(arguments.struct[key[i]])) content = arguments.struct[key[i]];
                    else                                    content = "<![CDATA[#arguments.struct[key[i]]#]]>";

                    xml = xml & tabs & this.tab & '<#name#>#content#</#name#>' & this.breaks;
                }

                // Get array sub elements
                else if(IsStruct(arguments.struct[key[i]]))
                {
                    xml = xml & tabs & this.tab & '<#name#>' & this.breaks;
                    xml = xml & StructToXml(struct=arguments.struct[key[i]], tab=tabsLen);
                    xml = xml & tabs & this.tab & '</#name#>' & this.breaks;
                }
            }

            if(NOT IsDefined("arguments.tab"))
                xml = xml & '</struct>' & this.breaks;

            /* Return or write the XML string in a file */
            switch(arguments.action)
            {
                case "return": return xml; break;
                case "write":  WriteToFile(arguments.file, Trim(xml), arguments.charset); break;
            }

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- XmlToArray --->
    <cffunction name="XmlToArray" access="public" output="no" returntype="array" hint="Converts a XML document object or a XML file to array.">

        <!--- Function Arguments --->
        <cfargument name="xmlObj"  required="no" type="any"                     hint="Parsed XML document object. Required if argument file is not set.">
        <cfargument name="file"    required="no" type="string"                  hint="Pathname or URL of the XML file to read. Required if argument xmlObj is not set.">
        <cfargument name="charset" required="no" type="string"  default="UTF-8" hint="The character encoding in which the XML file contents is encoded.">

        <cfscript>

            /* Default variables */
            var array = "";

            /* Create array */
            if(IsDefined("arguments.file")) query = XmlToQuery(file=arguments.file, charset=arguments.charset);
            else                            query = XmlToQuery(xmlObj=arguments.xmlObj);

            array = QueryToArray(query);

            /* Return array */
            return array;

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- XmlToCsv --->
    <cffunction name="XmlToCsv" access="public" output="no" returntype="string" hint="Converts a XML document object or a XML file to CSV.">

        <!--- Function Arguments --->
        <cfargument name="xmlObj"      required="no" type="any"                                         hint="Parsed XML document object. Required if argument file is not set.">
        <cfargument name="file"        required="no" type="string"                                      hint="Pathname or URL of the XML file to read. Required if argument xmlObj is not set.">
        <cfargument name="charset"     required="no" type="string"  default="UTF-8"                     hint="The character encoding in which the XML file contents is encoded.">
        <cfargument name="action"      required="no" type="string"  default="return"                    hint="Return or write the CSV string in a file.">
        <cfargument name="headerFirst" required="no" type="boolean" default="yes"                       hint="Set column names at first row.">
        <cfargument name="delimiter"   required="no" type="string"  default=";"                         hint="Character(s) that delimited the fileds.">
        <cfargument name="enclosed"    required="no" type="string"  default=""""                        hint="Character(s) that enclosed the field.">
        <cfargument name="empty"       required="no" type="string"  default=""                          hint="String that replace a empty field.">
        <cfargument name="csvFile"     required="no" type="string"  default="#ExpandPath(".")#\xml.csv" hint="Pathname of the CSV file to write.">
        <cfargument name="csvCharset"  required="no" type="string"  default="ISO-8859-1"                hint="The character encoding in which the CSV file contents is encoded.">

        <cfscript>

            /* Default variables */
            var csv   = "";

            /* Create CSV string */
            if(IsDefined("arguments.file")) query = XmlToQuery(file=arguments.file, charset=arguments.charset);
            else                            query = XmlToQuery(xmlObj=arguments.xmlObj);

            csv = QueryToCsv(query       = query,
                             headerFirst = arguments.headerFirst,
                             delimiter   = arguments.delimiter,
                             enclosed    = arguments.enclosed,
                             empty       = arguments.empty);

            /* Return or write the CSV string in a file */
            switch(arguments.action)
            {
                case "return": return csv; break;
                case "write":  WriteToFile(arguments.csvFile, Trim(csv), arguments.csvCharset); break;
            }

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- XmlToQuery --->
    <cffunction name="XmlToQuery" access="public" output="no" hint="Converts a XML document object or a XML file to query.">

        <!--- Function Arguments --->
        <cfargument name="xmlObj"  required="no" type="any"                    hint="Parsed XML document object. Required if argument file is not set.">
        <cfargument name="file"    required="no" type="string"                 hint="Pathname or URL of the XML file to read. Required if argument xmlObj is not set.">
        <cfargument name="charset" required="no" type="string" default="UTF-8" hint="The character encoding in which the XML file contents is encoded.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var n = 0;
            var childCurrent = "";
            var childLast    = "";

            if(NOT IsDefined("arguments.xmlData"))
            {
                query = QueryNew("");

                if(IsDefined("arguments.file"))
                    xmlObj = XmlParseFile(arguments.file, arguments.charset);

                if(StructKeyExists(xmlObj, "xmlRoot"))
                    XmlToQuery(xmlData=xmlObj.xmlRoot);
                else
                    XmlToQuery(xmlData=xmlObj);
            }

            else
            {
                for(i=1; i LTE ArrayLen(arguments.xmlData.xmlChildren); i=i+1)
                {
                    /* Create a struct with the Children and Attributes data */
                    data = StructNew();
                    data[REReplace(arguments.xmlData.xmlChildren[i].xmlName, "[^A-Za-z0-9]", "_", "ALL")] = arguments.xmlData.xmlChildren[i].xmlText;
                    StructAppend(data, arguments.xmlData.xmlChildren[i].xmlAttributes);

                    /* Append previous data to current data struct */
                    if(IsDefined("arguments.prevData"))
                        StructAppend(data, arguments.prevData);

                    names = StructKeyArray(data);

                    /* Set the current children name */
                    childCurrent = arguments.xmlData.xmlChildren[i].xmlName;

                    /* Create a new row if the query is empty or the current children name is the same as the last children name */
                    if(query.recordcount EQ 0 OR childCurrent EQ childLast)
                        QueryAddRow(query);

                    /* Set the last children name */
                    childLast = arguments.xmlData.xmlChildren[i].xmlName;

                    /* Loop over the element names */
                    for(n=1; n LTE ArrayLen(names); n=n+1)
                    {
                        colName = names[n];
                        colData = Trim(Evaluate("data.#names[n]#"));

                        // removed restrictions to not return a column
                        // when a node did not have any text data
                        //if(colData NEQ "")
                        //{
                            // Create column
                            if(ListFindNoCase(query.ColumnList, colName) EQ 0)
                                QueryAddColumn(query, colName, ArrayNew(1));

                            // Set data
                            QuerySetCell(query, colName, colData, query.recordcount);
                        //}
                    }

                    /* Get recursive data */
                    if(ArrayLen(arguments.xmlData.xmlChildren[i].xmlChildren) GT 0)
                        XmlToQuery(xmlData=arguments.xmlData.xmlChildren[i], prevData=data);
                }
            }

            /* Return query */
            if(NOT IsDefined("arguments.xmlData"))
                return query;

        </cfscript>
        
        <!---
        <cfdump var="#names#">
        <cfabort>
        --->
        
    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- XmlToStruct --->
    <cffunction name="XmlToStruct" access="public" output="no" returntype="struct" hint="Converts a XML document object or a XML file to struct.">

        <!--- Function Arguments --->
        <cfargument name="xmlObj"  required="no" type="any"                     hint="Parsed XML document object. Required if argument file is not set.">
        <cfargument name="file"    required="no" type="string"                  hint="Pathname or URL of the XML file to read. Required if argument xmlObj is not set.">
        <cfargument name="charset" required="no" type="string"  default="UTF-8" hint="The character encoding in which the XML file contents is encoded.">

        <cfscript>

            /* Default variables */
            var struct = "";

            /* Create array */
            if(IsDefined("arguments.file")) query = XmlToQuery(file=arguments.file, charset=arguments.charset);
            else                            query = XmlToQuery(xmlObj=arguments.xmlObj);

            struct = QueryToStruct(query);

            /* Return struct */
            return struct;

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- XmlParseFile --->
    <cffunction name="XmlParseFile" access="public" output="no" hint="Read and parse a XML file.">

        <!--- Function Arguments --->
        <cfargument name="file"    required="yes" type="string"                 hint="Pathname or URL of the XML file to read.">
        <cfargument name="charset" required="no"  type="string" default="UTF-8" hint="The character encoding in which the XML file contents is encoded.">

        <!--- Read XML file --->
        <cfset xmlData = ReadFile(arguments.file, arguments.charset)>

        <!--- Return parsed data --->
        <cfreturn xmlParse(xmlData)>

    </cffunction>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- Private functions for this component --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <!--- -------------------------------------------------- --->
    <!--- IsString --->
    <cffunction name="IsString" access="private" output="no" returntype="boolean" hint="Checked if the specified object is a string.">

        <!--- Function Arguments --->
        <cfargument name="object" required="yes" type="any" hint="The object to check.">

        <cftry>
            <cfset temp = Len(arguments.object)>
            <cfreturn true>

            <!--- Return false if the object is not a string --->
            <cfcatch type="coldfusion.runtime.CfJspPage$ComplexObjectException">
                <cfreturn false>
            </cfcatch>
        </cftry>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- WriteToFile --->
    <cffunction name="WriteToFile" access="private" output="no" hint="Write a file.">

        <!--- Function Arguments --->
        <cfargument name="file"    required="yes" type="string" hint="Pathname of the file to write.">
        <cfargument name="output"  required="yes" type="string" hint="Content of the file to be created.">
        <cfargument name="charset" required="no"  type="string" hint="The character encoding in which the file contents is encoded.">

        <cfif FindNoCase("Windows", this.os)>
            <cfset arguments.file = Replace(arguments.file, "/", "\", "ALL")>
        <cfelse>
            <cfset arguments.file = Replace(arguments.file, "\", "/", "ALL")>
        </cfif>

        <cffile action     = "write"
                file       = "#arguments.file#"
                output     = "#arguments.output#"
                charset    = "#arguments.charset#"
                addNewLine = "no">

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- ReadFile --->
    <cffunction name="ReadFile" access="private" output="no" hint="Read a file.">

        <!--- Function Arguments --->
        <cfargument name="file"    required="yes" type="string" hint="Pathname or URL of the file to read.">
        <cfargument name="charset" required="no"  type="string" hint="The character encoding in which the file contents is encoded.">

        <!--- Read local file --->
        <cfif FileExists(arguments.file)>

            <cfif FindNoCase("Windows", this.os)>
                <cfset arguments.file = Replace(arguments.file, "/", "\", "ALL")>
            <cfelse>
                <cfset arguments.file = Replace(arguments.file, "\", "/", "ALL")>
            </cfif>

            <cffile action   = "read"
                    file     = "#arguments.file#"
                    charset  = "#arguments.charset#"
                    variable = "content">

        <!--- Read file from URL --->
        <cfelse>

            <cfif Left(arguments.file,7) EQ "http://">
                <cfset port = "80">
            <cfelseif Left(arguments.file,8) EQ "https://">
                <cfset port = "443">
            <cfelse>
                <cfset arguments.file = "http://" & arguments.file>
                <cfset port = "80">
            </cfif>

            <cfhttp url     = "#arguments.file#"
                    port    = "#port#"
                    method  = "GET"
                    charset = "#arguments.charset#" />

            <cfset content = cfhttp.FileContent>

        </cfif>

        <!--- Return file content --->
        <cfreturn content>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- CsvOptRow --->
    <cffunction name="CsvOptRow" access="private" output="no" returntype="string" hint="Remove enclosed character(s) and set space between double delimiter.">

        <!--- Function Arguments --->
        <cfargument name="string"    required="yes" type="string" hint="The CSV row to optimize.">
        <cfargument name="delimiter" required="yes" type="string" hint="Character(s) that delimited the fields.">
        <cfargument name="enclosed"  required="yes" type="string" hint="Character(s) that enclosed the fields.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var str = arguments.string;
            var del = arguments.delimiter;
            var enc = arguments.enclosed;

            /* Set space between double delimiter */
            while(Find(del & del, str, 0) GT 0)
                str = Replace(str, del & del, del & " " & del, "ALL");

            /* Remove enclosed */
            for(i=1; i LTE ListLen(str, del); i=i+1)
            {
                element = ListGetAt(str, i, del);

                if(element NEQ "" AND Left(element, 1) EQ enc AND Right(element, 1) EQ enc)
                {
                    if(Len(element) GTE 3) count = Len(element)-2;
                    else                   count = 0;

                    str = ListSetAt(str, i, Mid(element, 2, count), del);
                }
            }

            /* Set space if first character is a delimiter */
            if(Left(str, 1) EQ del)
                str = " " & str;

            /* Return string */
            return str;

        </cfscript>

    </cffunction>

    <!--- -------------------------------------------------- --->
    <!--- CsvHeader --->
    <cffunction name="CsvHeader" access="private" output="no" returntype="string" hint="Create a list with the column names.">

        <!--- Function Arguments --->
        <cfargument name="string"      required="yes" type="string"  hint="The CSV row with the column names.">
        <cfargument name="headerFirst" required="yes" type="boolean" hint="Column names at the first row.">
        <cfargument name="delimiter"   required="yes" type="string"  hint="Character(s) that delimited the fields.">
        <cfargument name="enclosed"    required="yes" type="string"  hint="Character(s) that enclosed the fields.">

        <cfscript>

            /* Default variables */
            var i = 0;
            var column = "";

            /* Get column names from first row */
            if(arguments.headerFirst EQ "yes")
            {
                column = CsvOptRow(arguments.string, arguments.delimiter, arguments.enclosed);
                column = Replace(column, " ", "_", "ALL");                                         // Replace all whitespaces
                column = REReplace(column, "[^A-Za-z0-9#arguments.delimiter#]", "_", "ALL");       // Replace all special characters
                column = REReplace(column, "#arguments.delimiter#_+", arguments.delimiter, "ALL"); // Remove underslash at column name beginning
                column = REReplace(column, "^_+", "");                                             // Remove underslash at column list beginning
                column = ListChangeDelims(column, ",", arguments.delimiter);                       // Change delimiter
            }

            /* Create column names */
            else
            {
                for(i=1; i LTE ListLen(arguments.string, arguments.delimiter); i=i+1)
                    column = ListAppend(column, "column_#i#");
            }

            /* Return column list */
            return column;

        </cfscript>

    </cffunction>

    <!--- formatApiRecords --->
    <cffunction name="formatApiRecords" returntype="array" access="public">
        <cfargument name="data" type="any" required="true" hint="data to be translated" />
        
        <cfscript>
            result = "";
            data = arguments.data;
            items = translateToQuery(data);
            result = queryToArrayOfStructures( items,ArrayNew(1) );
        </cfscript>

        <cfreturn result />
    </cffunction>

    <!--- formatRecords --->
    <cffunction name="formatRecords" returntype="any" access="public">
        <cfargument name="data" type="any" required="true" hint="data to be translated" />
        <cfargument name="format" type="string" required="true" hint="Data format to return." />
        
        <cfscript>
            data = arguments.data;
            switch (arguments.format)
            {
                case "query":
                    items = translateToQuery(data);
                    break;
                case "json":
                    items = translateToJSON(data);
                    break;
                    
                default:
                    items = data;
            }
            
        </cfscript>

        <cfreturn items />
    </cffunction>   

    <!--- translateToQuery --->
    <cffunction name="translateToQuery" returntype="query" access="public">
        <cfargument name="data" type="any" required="true" hint="data to be translated" />
    	
        <cfset items = EntityToQuery(arguments.data)>
		
        <cfreturn items />
    </cffunction>

    <!--- translateToJSON --->
    <cffunction name="translateToJSON" returntype="any" access="public">
        <cfargument name="data" type="any" required="true" hint="data to be translated" />
    
        <cfset items = SerializeJSON(arguments.data)>

        <cfreturn items />
    </cffunction>
    
</cfcomponent>