<?php

namespace Tests\App\Services\Validators\Auth;

use App\Http\Request;
use App\Services\Validators\Validator;

class ValidatorTest extends \TestCase
{
  private $validator;

  protected function setUp() {
    $this->validator = $this->spy(ValidatorImpl::class, null);
  }

  public function testAttachErrorsToResponse() {
    $this->validator->addError('detail-1-1', 'pointer-1');
    $this->validator->addError('detail-1-2', 'pointer-1');
    $this->validator->addError('detail-2-1', 'pointer-2');

    $response = $this->mock('App\Http\Response');
    $response->shouldReceive('addApiErrorWithPointer')->with('detail-1-1', 'pointer-1');
    $response->shouldReceive('addApiErrorWithPointer')->with('detail-1-2', 'pointer-1');
    $response->shouldReceive('addApiErrorWithPointer')->with('detail-2-1', 'pointer-2');

    $this->validator->attachErrorsToResponse($response);
  }

  public function testIsValidNumericIdIsFalse() {
    $zero = $this->invokeObjectMethodWithClass(Validator::class, $this->validator, 'isValidNumericId', [0]);
    $string = $this->invokeObjectMethodWithClass(Validator::class, $this->validator, 'isValidNumericId', ['1']);
    $null = $this->invokeObjectMethodWithClass(Validator::class, $this->validator, 'isValidNumericId', [null]);
    $this->assertFalse($zero, 'Must be greater than 0');
    $this->assertFalse($string, 'May not be string');
    $this->assertFalse($null, 'May not be null');
  }

  public function testIsValidNumericId() {
    $this->assertTrue($this->invokeObjectMethodWithClass(Validator::class, $this->validator, 'isValidNumericId', [1]));
  }

  public function testIsValidSequenceIsFalse() {
    $string = $this->invokeObjectMethodWithClass(Validator::class, $this->validator, 'isValidSequence', ['1']);
    $null = $this->invokeObjectMethodWithClass(Validator::class, $this->validator, 'isValidSequence', [null]);
    $this->assertFalse($string, 'May not be string');
    $this->assertFalse($null, 'May not be null');
  }

  public function testIsValidSequence() {
    $this->assertTrue($this->invokeObjectMethodWithClass(Validator::class, $this->validator, 'isValidSequence', [-1]));
    $this->assertTrue($this->invokeObjectMethodWithClass(Validator::class, $this->validator, 'isValidSequence', [0]));
    $this->assertTrue($this->invokeObjectMethodWithClass(Validator::class, $this->validator, 'isValidSequence', [1]));
  }
}

class ValidatorImpl extends Validator {
  public function validate(Request $request) {}
}