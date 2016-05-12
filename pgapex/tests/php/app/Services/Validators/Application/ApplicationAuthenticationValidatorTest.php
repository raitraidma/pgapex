<?php

namespace Tests\App\Services\Validators\Application;

use App\Services\Validators\Application\ApplicationAuthenticationValidator;

class ApplicationAuthenticationValidatorTest extends \TestCase
{
  private $validator;
  private $request;

  protected function setUp() {
    $this->validator = $this->spy(ApplicationAuthenticationValidator::class);
    $this->request = $this->mock('App\Http\Request');
  }

  public function testValidateAuthenticationSchemeIsUserFunction() {
    $this->request->shouldReceive('getApiAttribute')->with('authenticationScheme', '')->andReturn('USER_FUNCTION');
    $this->invokeObjectMethod($this->validator, 'validateAuthenticationScheme', [$this->request]);
    $this->assertEquals(0, count($this->validator->getErrors()));
  }

  public function testValidateAuthenticationSchemeIsNoAuthentication() {
    $this->request->shouldReceive('getApiAttribute')->with('authenticationScheme', '')->andReturn('NO_AUTHENTICATION');
    $this->invokeObjectMethod($this->validator, 'validateAuthenticationScheme', [$this->request]);
    $this->assertEquals(0, count($this->validator->getErrors()));
  }

  public function testValidateAuthenticationSchemeIsInvalid() {
    $this->request->shouldReceive('getApiAttribute')->with('authenticationScheme', '')->andReturn('OTHER');
    $this->invokeObjectMethod($this->validator, 'validateAuthenticationScheme', [$this->request]);
    $errors = $this->validator->getErrors();
    $this->assertEquals(1, count($errors));
    $this->assertEquals('application.suchAuthenticationSchemeDoesNotExist', $errors['/data/attributes/authenticationScheme'][0]);
  }

  public function testValidateAuthenticationFunctionIsCorrect() {
    $this->request->shouldReceive('getApiAttribute')->with('authenticationFunction', '')->andReturn([
      'database' => 'databaseName', 'schema' => 'schemaName', 'function' => 'functionName'
    ]);
    $this->validator->shouldReceive('authenticationSchemeIsUserFunction')->andReturn(true);
    $this->invokeObjectMethod($this->validator, 'validateAuthenticationFunction', [$this->request]);
    $this->assertEquals(0, count($this->validator->getErrors()));
  }

  public function testValidateAuthenticationFunctionIsMissingDatabase() {
    $this->request->shouldReceive('getApiAttribute')->with('authenticationFunction', '')->andReturn([
      'database' => '', 'schema' => 'schemaName', 'function' => 'functionName'
    ]);
    $this->validator->shouldReceive('authenticationSchemeIsUserFunction')->andReturn(true);
    $this->invokeObjectMethod($this->validator, 'validateAuthenticationFunction', [$this->request]);
    $errors = $this->validator->getErrors();
    $this->assertEquals(1, count($errors));
    $this->assertEquals('application.suchFunctionDoesNotExist', $errors['/data/attributes/authenticationFunction'][0]);
  }

  public function testValidateAuthenticationFunctionIsMissingSchema() {
    $this->request->shouldReceive('getApiAttribute')->with('authenticationFunction', '')->andReturn([
      'database' => 'databaseName', 'schema' => '', 'function' => 'functionName'
    ]);
    $this->validator->shouldReceive('authenticationSchemeIsUserFunction')->andReturn(true);
    $this->invokeObjectMethod($this->validator, 'validateAuthenticationFunction', [$this->request]);
    $errors = $this->validator->getErrors();
    $this->assertEquals(1, count($errors));
    $this->assertEquals('application.suchFunctionDoesNotExist', $errors['/data/attributes/authenticationFunction'][0]);
  }

  public function testValidateAuthenticationFunctionIsMissingFunction() {
    $this->request->shouldReceive('getApiAttribute')->with('authenticationFunction', '')->andReturn([
      'database' => 'databaseName', 'schema' => 'schemaName', 'function' => ''
    ]);
    $this->validator->shouldReceive('authenticationSchemeIsUserFunction')->andReturn(true);
    $this->invokeObjectMethod($this->validator, 'validateAuthenticationFunction', [$this->request]);
    $errors = $this->validator->getErrors();
    $this->assertEquals(1, count($errors));
    $this->assertEquals('application.suchFunctionDoesNotExist', $errors['/data/attributes/authenticationFunction'][0]);
  }

  public function testAuthenticationSchemeIsUserFunctionIsTrue() {
    $this->request->shouldReceive('getApiAttribute')->with('authenticationScheme')->andReturn('USER_FUNCTION');
    $result = $this->invokeObjectMethod($this->validator, 'authenticationSchemeIsUserFunction', [$this->request]);
    $this->assertTrue($result);
  }

  public function testAuthenticationSchemeIsUserFunctionIsFalse() {
    $this->request->shouldReceive('getApiAttribute')->with('authenticationScheme')->andReturn('NO_AUTHENTICATION');
    $result = $this->invokeObjectMethod($this->validator, 'authenticationSchemeIsUserFunction', [$this->request]);
    $this->assertFalse($result);
  }

  public function testValidateLoginPageTemplateIsCorrect() {
    $this->request->shouldReceive('getApiAttribute')->with('loginPageTemplate')->andReturn(1);
    $this->validator->shouldReceive('authenticationSchemeIsUserFunction')->andReturn(true);
    $this->invokeObjectMethod($this->validator, 'validateLoginPageTemplate', [$this->request]);
    $this->assertEquals(0, count($this->validator->getErrors()));
  }

  public function testValidateLoginPageTemplateMustBeANumber() {
    $this->request->shouldReceive('getApiAttribute')->with('loginPageTemplate')->andReturn('1');
    $this->validator->shouldReceive('authenticationSchemeIsUserFunction')->andReturn(true);
    $this->invokeObjectMethod($this->validator, 'validateLoginPageTemplate', [$this->request]);
    $errors = $this->validator->getErrors();
    $this->assertEquals(1, count($errors));
    $this->assertEquals('application.suchLoginPageTemplateDoesNotExist', $errors['/data/attributes/loginPageTemplate'][0]);
  }
}