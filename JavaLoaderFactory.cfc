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

		<bean id="javaLoaderFactory" class="JavaLoaderFactory" />

		<bean id="javaLoader" factory-bean="javaLoaderFactory" factory-method="getJavaLoader">
			<constructor-arg name="loadPaths">
				<list>
					<value>/opencsv/opencsv-2.2.jar</value>
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

	function init( numeric lockTimeout = 60 )
	{
		variables.lockTimeout = arguments.lockTimeout;

		return this;
	}


	/********** PUBLIC ********************************************************/


	function getJavaLoader( required array loadPaths, boolean loadColdFusionClassPath, string parentClassLoader, boolean expandLoadPaths = true, string serverKey )
	{
		var initArgs = { loadPaths = arguments.loadPaths };

		if ( structKeyExists( arguments, 'loadColdFusionClassPath' ) )
			initArgs.loadColdFusionClassPath = arguments.loadColdFusionClassPath;

		if ( structKeyExists( arguments, 'parentClassLoader' ) )
			initArgs.parentClassLoader = arguments.parentClassLoader;

		if ( expandLoadPaths )
		{
			for ( var i = 1; i <= arrayLen( initArgs.loadPaths ); i++ )
			{
				initArgs.loadPaths[ i ] = expandPath( initArgs.loadPaths[ i ] );
			}
		}

		var _serverKey = structKeyExists( arguments, 'serverKey' ) ? arguments.serverKey : hash( serializeJSON( initArgs ) );

		if ( !structKeyExists( server, _serverKey ) )
		{
			lock name='server.#_serverKey#' timeout='#variables.lockTimeout#'
			{
				if ( !structKeyExists( server, _serverKey ) )
					server[ _serverKey ] = createObject( 'component', 'javaloader.JavaLoader' ).init( argumentCollection = initArgs );
			}
		}

		return server[ _serverKey ];
	}


	/********** PRIVATE *******************************************************/


}