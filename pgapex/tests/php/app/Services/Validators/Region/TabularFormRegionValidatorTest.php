<?php

namespace Tests\App\Services\Validators\Auth;

use App\Services\Validators\Region\TabularFormRegionValidator;

class TabularFormRegionValidatorTest extends \TestCase {
  private $validator;
  private $request;

  protected function setUp() {
    $this->validator = $this->spy(TabularFormRegionValidator::class, null);
    $this->request = $this->mock('App\Http\Request');
  }

  public function testValidateTabularFormTemplate() {
    $this->request->shouldReceive('getApiAttribute')->with('tabularFormTemplate')->andReturn(null);
    $this->invokeObjectMethod($this->validator, 'validateTabularFormTemplate', [$this->request]);
    $this->assertEquals(1, count($this->validator->getErrors()));

    $this->request->shouldReceive('getApiAttribute')->with('tabularFormTemplate')->andReturn(-1);
    $this->invokeObjectMethod($this->validator, 'validateTabularFormTemplate', [$this->request]);
    $this->assertEquals(1, count($this->validator->getErrors()));
  }

  public function testValidateView() {
    $this->request->shouldReceive('getApiAttribute')->with('viewSchema')->andReturn('public');
    $this->request->shouldReceive('getApiAttribute')->with('viewName')->andReturn(null);
    $this->invokeObjectMethod($this->validator, 'validateView', [$this->request]);

    $this->assertEquals(1, count($this->validator->getErrors()));
  }

  public function testValidateItemsPerPage() {
    $this->request->shouldReceive('getApiAttribute')->with('itemsPerPage')->andReturn(null);
    $this->invokeObjectMethod($this->validator, 'validateItemsPerPage', [$this->request]);

    $this->assertEquals(1, count($this->validator->getErrors()));
  }

  public function testValidatePaginationQueryParameter() {
    $this->request->shouldReceive('getApiAttribute')->with('paginationQueryParameter')->andReturn(null);
    $this->invokeObjectMethod($this->validator, 'validatePaginationQueryParameter', [$this->request]);
    $this->assertEquals(1, count($this->validator->getErrors()));

    $this->request->shouldReceive('getApiAttribute')->with('paginationQueryParameter')->andReturn('page-1');
    $this->invokeObjectMethod($this->validator, 'validatePaginationQueryParameter', [$this->request]);
    $this->assertEquals(1, count($this->validator->getErrors()));

    $this->request->shouldReceive('getApiAttribute')->with('paginationQueryParameter')->andReturn(-1);
    $this->invokeObjectMethod($this->validator, 'validatePaginationQueryParameter', [$this->request]);
    $this->assertEquals(1, count($this->validator->getErrors()));
  }

  public function testValidateColumnsWithoutLink() {
    $columns = [
      array(
      'type' => 'tabularform-column',
      'attributes' => array(
        'column' => 'column_example_1',
        'heading' => 'HeadingExample_1',
        'isTextEscaped' => true,
        'sequence' => 1,
        'type' => 'COLUMN'
        )
      ),
      array(
        'type' => 'tabularform-column',
        'attributes' => array(
          'column' => 'column_example_1',
          'heading' => '',
          'isTextEscaped' => true,
          'sequence' => 1,
          'type' => 'COLUMN'
        )
      )
    ];

    $this->request->shouldReceive('getApiAttribute')->with('tabularFormColumns')->andReturn($columns);
    $this->invokeObjectMethod($this->validator, 'validateColumns', [$this->request, 'tabularForm']);
    $this->assertEquals(2, count($this->validator->getErrors()));
  }

}