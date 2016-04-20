<?php

class TestCase extends \PHPUnit_Framework_TestCase
{
    /**
     * Make method accessible. Change method's visibility.
     *
     * @param string $class
     * @param string $method
     * @return ReflectionMethod
     */
    public function makeClassMethodAccessible($class, $method) {
        $classMethod = new ReflectionMethod($class, $method);
        $classMethod->setAccessible(true);
        return $classMethod;
    }

    /**
     * Make property accessible.
     *
     * @param string $class
     * @param string $property
     * @return ReflectionProperty
     */
    public function makeClassPropertyAccessible($class, $property) {
        $classProperty = new ReflectionProperty($class, $property);
        $classProperty->setAccessible(true);
        return $classProperty;
    }

    /**
     * Invoke method of an object.
     *
     * @param $instance
     * @param string $method
     * @param array $parameters
     * @return mixed
     */
    public function invokeObjectMethod($instance, $method, $parameters = []) {
        $classMethod = $this->makeClassMethodAccessible(get_class($instance), $method);
        return $classMethod->invokeArgs($instance, $parameters);
    }

    /**
     * Get property value of an object.
     *
     * @param $instance
     * @param string $property
     * @return mixed
     */
    public function getObjectProperty($instance, $property) {
        $classProperty = $this->makeClassPropertyAccessible(get_class($instance), $property);
        return $classProperty->getValue($instance);
    }

    /**
     * Create mocking class.
     * Can mock protected methods.
     *
     * @param $class
     * @return \Mockery\Mock
     */
    public function mock($class) {
        return Mockery::mock($class)->shouldAllowMockingProtectedMethods();
    }

    /**
     * Create spying class.
     * Can spy on protected methods.
     * Methods that are not mocked will be called as they are.
     *
     * @param $class
     * @return \Mockery\Mock
     */
    public function spy($class) {
        return Mockery::spy($class)->shouldAllowMockingProtectedMethods()->makePartial();
    }
}