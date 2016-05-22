<?php

namespace Tests\App\Services\Validators\Application;

use App\Services\Validators\Application\ApplicationValidator;

class ApplicationValidatorTest extends \TestCase
{
  private $validator;
  private $request;

  protected function setUp() {
    $this->validator = $this->spy(ApplicationValidator::class, null);
    $this->request = $this->mock('App\Http\Request');
  }

  public function testValidateNameIsCorrect() {
    $this->request->shouldReceive('getApiAttribute')->with('id')->andReturn(1);
    $this->request->shouldReceive('getApiAttribute')->with('name', '')->andReturn(' Application name ');
    $this->validator->shouldReceive('applicationMayHaveAName')->andReturn(true);
    $this->invokeObjectMethod($this->validator, 'validateName', [$this->request]);
    $this->assertEquals(0, count($this->validator->getErrors()));
  }

  public function testValidateNameWithSpaces() {
    $this->request->shouldReceive('getApiAttribute')->with('id')->andReturn(1);
    $this->request->shouldReceive('getApiAttribute')->with('name', '')->andReturn(' ');
    $this->invokeObjectMethod($this->validator, 'validateName', [$this->request]);
    $errors = $this->validator->getErrors();
    $this->assertEquals(1, count($errors));
    $this->assertEquals('application.applicationNameIsMandatory', $errors['/data/attributes/name'][0]);
  }

  public function testValidateNameAlreadyExists() {
    $this->request->shouldReceive('getApiAttribute')->with('id')->andReturn(1);
    $this->request->shouldReceive('getApiAttribute')->with('name', '')->andReturn('Application name');
    $this->validator->shouldReceive('applicationMayHaveAName')->andReturn(false);
    $this->invokeObjectMethod($this->validator, 'validateName', [$this->request]);
    $errors = $this->validator->getErrors();
    $this->assertEquals(1, count($errors));
    $this->assertEquals('application.applicationNameAlreadyExists', $errors['/data/attributes/name'][0]);
  }

  public function testValidateAliasIsInvalid() {
    $this->request->shouldReceive('getApiAttribute')->with('alias', '')->andReturn('alias');
    $this->request->shouldReceive('getApiAttribute')->with('id')->andReturn(1);
    $this->validator->shouldReceive('aliasContainsCharactersAndMayContainNumbersAndUnderscores')->andReturn(false);

    $this->invokeObjectMethod($this->validator, 'validateAlias', [$this->request]);
    $errors = $this->validator->getErrors();
    $this->assertEquals(1, count($errors));
    $this->assertEquals('application.applicationAliasMustContainCharacters', $errors['/data/attributes/alias'][0]);
  }

  public function testValidateAliasAlreadyExists() {
    $this->request->shouldReceive('getApiAttribute')->with('alias', '')->andReturn('alias');
    $this->request->shouldReceive('getApiAttribute')->with('id')->andReturn(1);
    $this->validator->shouldReceive('aliasContainsCharactersAndMayContainNumbersAndUnderscores')->andReturn(true);
    $this->validator->shouldReceive('applicationMayHaveAnAlias')->andReturn(false);

    $this->invokeObjectMethod($this->validator, 'validateAlias', [$this->request]);
    $errors = $this->validator->getErrors();
    $this->assertEquals(1, count($errors));
    $this->assertEquals('application.aliasAlreadyExists', $errors['/data/attributes/alias'][0]);
  }

  public function testAliasMustContainCharactersAndMayContainNumbersAndUnderscoresIsFalse() {
    $method = 'aliasContainsCharactersAndMayContainNumbersAndUnderscores';
    $empty = $this->invokeObjectMethodWithClass(ApplicationValidator::class, $this->validator, $method, ['']);
    $containsSpace = $this->invokeObjectMethodWithClass(ApplicationValidator::class, $this->validator, $method, ['a 1']);
    $spaceOnly = $this->invokeObjectMethodWithClass(ApplicationValidator::class, $this->validator, $method, [' ']);
    $numbersOnly = $this->invokeObjectMethodWithClass(ApplicationValidator::class, $this->validator, $method, ['123']);
    $numberAndUnderscore = $this->invokeObjectMethodWithClass(ApplicationValidator::class, $this->validator, $method, ['1_']);

    $this->assertFalse($empty, 'May not be empty');
    $this->assertFalse($containsSpace, 'May not contain space');
    $this->assertFalse($spaceOnly, 'May not consist of spaces');
    $this->assertFalse($numbersOnly, 'May not consist of numbers');
    $this->assertFalse($numberAndUnderscore, 'May not contain only numbers and underscores');
  }

  public function testAliasMustContainCharactersAndMayContainNumbersAndUnderscoresIsTrue() {
    $method = 'aliasContainsCharactersAndMayContainNumbersAndUnderscores';
    $charAndUnderscore = $this->invokeObjectMethodWithClass(ApplicationValidator::class, $this->validator, $method, ['a_']);
    $charAndNumber = $this->invokeObjectMethodWithClass(ApplicationValidator::class, $this->validator, $method, ['a1']);

    $this->assertTrue($charAndUnderscore);
    $this->assertTrue($charAndNumber);
  }

  public function testValidateDatabaseIsCorrect() {
    $this->request->shouldReceive('getApiAttribute')->with('database', '')->andReturn('database');
    $this->invokeObjectMethod($this->validator, 'validateDatabase', [$this->request]);
    $this->assertEquals(0, count($this->validator->getErrors()));
  }

  public function testValidateDatabaseIsEmpty() {
    $this->request->shouldReceive('getApiAttribute')->with('database', '')->andReturn(' ');
    $this->invokeObjectMethod($this->validator, 'validateDatabase', [$this->request]);
    $errors = $this->validator->getErrors();
    $this->assertEquals(1, count($errors));
    $this->assertEquals('application.databaseIsMandatory', $errors['/data/attributes/database'][0]);
  }

  public function testValidateDatabaseUsernameIsCorrect() {
    $this->request->shouldReceive('getApiAttribute')->with('databaseUsername', '')->andReturn('username');
    $this->invokeObjectMethod($this->validator, 'validateDatabaseUsername', [$this->request]);
    $this->assertEquals(0, count($this->validator->getErrors()));
  }

  public function testValidateDatabaseUsernameIsEmpty() {
    $this->request->shouldReceive('getApiAttribute')->with('databaseUsername', '')->andReturn(' ');
    $this->invokeObjectMethod($this->validator, 'validateDatabaseUsername', [$this->request]);
    $errors = $this->validator->getErrors();
    $this->assertEquals(1, count($errors));
    $this->assertEquals('application.databaseUsernameIsMandatory', $errors['/data/attributes/databaseUsername'][0]);
  }

  public function testValidateDatabasePasswordIsCorrect() {
    $this->request->shouldReceive('getApiAttribute')->with('databasePassword', '')->andReturn('password');
    $this->invokeObjectMethod($this->validator, 'validateDatabasePassword', [$this->request]);
    $this->assertEquals(0, count($this->validator->getErrors()));
  }

  public function testValidateDatabasePasswordIsEmpty() {
    $this->request->shouldReceive('getApiAttribute')->with('databasePassword', '')->andReturn(' ');
    $this->invokeObjectMethod($this->validator, 'validateDatabasePassword', [$this->request]);
    $errors = $this->validator->getErrors();
    $this->assertEquals(1, count($errors));
    $this->assertEquals('application.databasePasswordIsMandatory', $errors['/data/attributes/databasePassword'][0]);
  }

  public function testValidateDatabaseUserCredentialsUserDoesNotExist() {
    $this->request->shouldReceive('getApiAttribute')->with('databaseUsername', '')->andReturn('user');
    $this->request->shouldReceive('getApiAttribute')->with('databasePassword', '')->andReturn('pass');
    $this->validator->shouldReceive('userExists')->andReturn(false);

    $this->invokeObjectMethod($this->validator, 'validateDatabaseUserCredentials', [$this->request]);
    $errors = $this->validator->getErrors();
    $this->assertEquals(1, count($errors));
    $this->assertEquals('application.usernameAndPasswordDoNotMatch', $errors['/data/attributes/databaseUsername'][0]);
  }
}