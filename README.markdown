JavaLoaderFactory.cfc
---------------------

A factory CFC to provide a facade for server-scoped instance(s) of [JavaLoader](http://javaloader.riaforge.org/). The [JavaLoader docs advise](http://www.compoundtheory.com/javaloader/docs/#Memory_Issues_424911073034682_) that instances be stored in the `server` scope. This factory abstracts this initialization work.

## API Overview

### init()

The `init()` method accepts two optional arguments: `lockTimeout` and `serverKey`. The `lockTimeout` argument specifies the lock timeout for creating a JavaLoader instance (with `getJavaLoader()`); the default is 60 (seconds). The `serverKey` argument allows you to explicitly name the server scope key that will hold the JavaLoader instance created/retrieved by `getJavaLoader()`. It is recommended that you **not** specify `serverKey`, because JavaLoaderFactory will automatically choose a sensible key that is unique to the JavaLoader `init()` arguments (see below).

### getJavaLoader()

`getJavaLoader()` is the factory method used to create your JavaLoader instance. If you call `getJavaLoader()` more than once with the same arguments (or with `serverKey` set), it will always return the same JavaLoader instance, from the `server` scope (though this should never happen if you're using ColdSpring or another bean factory--see example below).

The first six arguments (all optional) match JavaLoader's `init()` arguments:

1. loadPaths (array)
2. loadColdFusionClassPath (boolean)
3. parentClassLoader (string)
4. sourceDirectories (array)
5. compileDirectory (string)
6. trustedSource (boolean)

The last `getJavaLoader()` argument, `loadRelativePaths`, is an optional array. Each array item should be a path relative to the Web root, which will be expanded with `expandPath()` and appended to the `loadPaths` argument. This argument simply allows passing relative paths for JavaLoader's `init()` argument of `loadPaths`. You can pass any combination of `loadPaths` and `loadRelativePaths` arguments (either, neither or both).

## Examples

Example [ColdSpring](http://coldspringframework.org/) bean factory configuration (assumes JavaLoaderFactory.cfc in Web root and /opencsv is a CFML mapping or in Web root):

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

Example usage (assumes above ColdSpring bean factory has been initialized and is accessible via `getBeanFactory()`):

	javaLoader = getBeanFactory().getBean( 'javaLoader' );

	csvReader = javaLoader.create( 'au.com.bytecode.opencsv.CSVReader' );

