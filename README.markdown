JavaLoaderFactory.cfc
---------------------

A factory CFC to provide a facade to server-scoped instance(s) of [JavaLoader](http://javaloader.riaforge.org/).

Example [ColdSpring](http://coldspringframework.org/) bean factory configuration (assumes JavaLoaderFactory.cfc in Web root and /opencsv is a CFML mapping or in Web root):

	<bean id="javaLoaderFactory" class="JavaLoaderFactory" />

	<bean id="javaLoader" factory-bean="javaLoaderFactory" factory-method="getJavaLoader">
		<constructor-arg name="loadPaths">
			<list>
				<value>/opencsv/opencsv-2.2.jar</value>
			</list>
		</constructor-arg>
	</bean>

Example usage (assumes above ColdSpring bean factory has been initilized and is accessible via `getBeanFactory()`):

	javaLoader = getBeanFactory().getBean( 'javaLoader' );

	csvReader = javaLoader.create( 'au.com.bytecode.opencsv.CSVReader' );

