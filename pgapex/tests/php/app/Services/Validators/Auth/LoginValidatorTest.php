<?php

namespace Tests\App\Services\Validators\Auth;

use App\Services\Validators\Auth\LoginValidator;

class LoginValidatorTest extends \TestCase
{
  public function testValidateWhenUsernameAndPasswordAreMissing() {
    $request = $this->mock('App\Http\Request');
    $request->shouldReceive('getApiAttribute')->with('username')->andReturn(null);
    $request->shouldReceive('getApiAttribute')->with('password')->andReturn(null);

    $validator = new LoginValidator();
    $validator->validate($request);
    $errors = $validator->getErrors();

    $this->assertEquals(2, count($errors));
    $this->assertEquals('auth.usernameIsMandatory', $errors['/data/attributes/username'][0]);
    $this->assertEquals('auth.passwordIsMandatory', $errors['/data/attributes/password'][0]);
  }
}