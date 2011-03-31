/*
Title:      JavaLoaderFactory.cfc

Source:     https://github.com/jamiekrug/JavaLoaderFactory

Author:     Jamie Krug
            http://identi.ca/jamiekrug
            http://twitter.com/jamiekrug
            http://jamiekrug.com/blog/

Purpose:    Factory to provide facade to server-scoped instance of
            JavaLoader (http://javaloader.riaforge.org/).

Example ColdSpring bean factory configuration:

	<bean id="javaLoaderFactory" class="JavaLoaderFactory.JavaLoaderFactory" />

	<bean id="javaLoader" factory-bean="javaLoaderFactory" factory-method="getJavaLoader">
		<constructor-arg name="loadPaths">
			<list>
				<value>/opt/XOM/xom-1.2.6.jar</value>
			</list>
		</constructor-arg>
		<constructor-arg name="loadRelativePaths">
			<list>
				<value>/../jars/opencsv-2.2.jar</value>
			</list>
		</constructor-arg>
	</bean>

Example usage:

	javaLoader = getBeanFactory().getBean( 'javaLoader' );

	csvReader = javaLoader.create( 'au.com.bytecode.opencsv.CSVReader' );

*/
component hint="Factory to provide facade to server instance of JavaLoader."
{

	/********** CONSTRUCTOR ***************************************************/

	function init( numeric lockTimeout = 60, string serverKey )
	{
		variables.lockTimeout = arguments.lockTimeout;

		if ( structKeyExists( arguments, 'serverKey' ) )
			variables.serverKey = arguments.serverKey;

		return this;
	}


	/********** PUBLIC ********************************************************/


	function getJavaLoader(
		array loadPaths,
		boolean loadColdFusionClassPath,
		string parentClassLoader,
		array sourceDirectories,
		string compileDirectory,
		boolean trustedSource,
		array loadRelativePaths
		)
	{
		var javaLoaderInitArgs = buildJavaLoaderInitArgs( argumentCollection = arguments );

		var _serverKey = calculateServerKey( javaLoaderInitArgs );

		if ( !structKeyExists( server, _serverKey ) )
		{
			lock name='server.#_serverKey#' timeout='#variables.lockTimeout#'
			{
				if ( !structKeyExists( server, _serverKey ) )
					server[ _serverKey ] = createObject( 'component', 'javaloader.JavaLoader' ).init( argumentCollection = javaLoaderInitArgs );
			}
		}

		return server[ _serverKey ];
	}


	/********** PRIVATE *******************************************************/


	private struct function buildJavaLoaderInitArgs(
		array loadPaths,
		boolean loadColdFusionClassPath,
		string parentClassLoader,
		array sourceDirectories,
		string compileDirectory,
		boolean trustedSource,
		array loadRelativePaths
		)
	{
		var initArgs = {};

		for ( var argName in [ 'loadPaths', 'loadColdFusionClassPath', 'parentClassLoader', 'sourceDirectories', 'compileDirectory', 'trustedSource'  ] )
		{
			if ( structKeyExists( arguments, argName ) )
				initArgs[ argName ] = arguments[ argName ];
		}

		if ( structKeyExists( arguments, 'loadRelativePaths' ) && arrayLen( arguments.loadRelativePaths ) )
		{
			if ( !structKeyExists( initArgs, 'loadPaths' ) )
				initArgs.loadPaths = [];

			for ( var relPath in arguments.loadRelativePaths )
			{
				arrayAppend( initArgs.loadPaths, expandPath( relPath ) );
			}
		}

		return initArgs;
	}


	private string function calculateServerKey( struct javaLoaderInitArgs )
	{
		// variables.serverKey takes precedence, if exists
		if ( structKeyExists( variables, 'serverKey' ) )
			return variables.serverKey;

		// hash init args, to generate unique key based on precise JavaLoader instance
		return hash( serializeJSON( { javaLoader = arguments.javaLoaderInitArgs } ) );
	}


}