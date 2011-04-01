/*
Title:      JavaLoaderFactoryBean.cfc

Web site:   https://github.com/jamiekrug/JavaLoaderFactory

Author:     Jamie Krug
            http://identi.ca/jamiekrug
            http://twitter.com/jamiekrug
            http://jamiekrug.com/blog/

Purpose:    ColdSpring factory bean to provide facade to server-scoped JavaLoader instance.

Example ColdSpring bean factory configuration:

	<bean id="javaLoader" class="JavaLoaderFactory.JavaLoaderFactoryBean">
		<property name="loadRelativePaths">
			<list>
				<value>/../jars/opencsv-2.2.jar</value>
			</list>
		</property>
		<property name="loadPaths">
			<list>
				<value>/opt/XOM/xom-1.2.6.jar</value>
			</list>
		</property>
	</bean>

Example usage:

	javaLoader = getBeanFactory().getBean( 'javaLoader' );

	csvReader = javaLoader.create( 'au.com.bytecode.opencsv.CSVReader' );

*/
component extends="coldspring.beans.factory.FactoryBean" accessors="true"
{
	property name="loadRelativePaths" type="array"
		hint="Relative paths that will be expanded and appended to loadPaths.";

	property name="lockTimeout" type="numeric" default="60"
		hint="Timeout, in seconds, for named lock used when instantiating JavaLoader instance in server scope.";

	property name="objectType" type="string" default="javaloader.JavaLoader"
		hint="Component path to JavaLoader, to allow for a non-standard CFC location (default is javaloader.JavaLoader).";

	property name="serverKey" type="string"
		hint="Server struct key to hold JavaLoader instance; recommend **not** specifying this argument, but it's here if you really want it.";

	property name="loadPaths"               type="array"   hint="See JavaLoader:init()";
	property name="loadColdFusionClassPath" type="boolean" hint="See JavaLoader:init()";
	property name="parentClassLoader"       type="string"  hint="See JavaLoader:init()";
	property name="sourceDirectories"       type="array"   hint="See JavaLoader:init()";
	property name="compileDirectory"        type="string"  hint="See JavaLoader:init()";
	property name="trustedSource"           type="boolean" hint="See JavaLoader:init()";
	property name="loadRelativePaths"       type="array"   hint="See JavaLoader:init()";


	/********** CONSTRUCTOR ***************************************************/


	function init()
		hint="Constructor"
	{
		return this;
	}


	/********** PUBLIC ********************************************************/


	function getObject()
		hint="Create/return server-scoped JavaLoader instance."
	{
		initLoadPaths();

		initServerKey();

		if ( !structKeyExists( server, getServerKey() ) )
		{
			lock name="#getLockName()#" timeout="#getLockTimeout()#"
			{
				if ( !structKeyExists( server, getServerKey() ) )
					server[ getServerKey() ] = createObject( "component", getObjectType() ).init( argumentCollection = getJavaLoaderInitArgs() );
			}
		}

		return server[ getServerKey() ];
	}


	string function getObjectType()
	{
		return variables.objectType;
	}


	boolean function isSingleton()
	{
		return true;
	}


	/********** PRIVATE *******************************************************/


	private string function createServerKey()
		hint="Create a server key unique to JavaLoader instance by hashing init args and objectType."
	{
		return hash( serializeJSON( { '#getObjectType()#' = getJavaLoaderInitArgs() } ) );
	}


	private struct function getJavaLoaderInitArgs()
		hint="Argument collection for JavaLoader:init()."
	{
		return {
			loadPaths = getLoadPaths(),
			loadColdFusionClassPath = getLoadColdFusionClassPath(),
			parentClassLoader = getParentClassLoader(),
			sourceDirectories = getSourceDirectories(),
			compileDirectory = getCompileDirectory(),
			trustedSource = getTrustedSource()
		};
	}


	private string function getLockName()
	{
		return 'server.#getServerKey()#';
	}


	private void function initLoadPaths()
		hint="Initialize JavaLoader load paths by appending any relative paths (loadRelativePaths), expanded, to any absolute paths (loadPaths)."
	{
		if ( !isNull( getLoadRelativePaths() ) )
		{
			var loadPaths = [];

			if ( !isNull( getLoadPaths() ) )
			{
				loadPaths = getLoadPaths();
			}

			for ( var relPath in getLoadRelativePaths() )
			{
				arrayAppend( loadPaths, expandPath( relPath ) );
			}

			setLoadPaths( loadPaths );

			setLoadRelativePaths( [] );
		}
	}


	private void function initServerKey()
		hint="Initialize server key name to hold JavaLoader instance, if not explicitly provided."
	{
		if ( isNull( getServerKey() ) )
		{
			setServerKey( createServerKey() );
		}
	}


}