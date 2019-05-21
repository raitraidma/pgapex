<?php

namespace Tests\App\Services\Validators\Auth;

use App\Services\Validators\Region\ReportAndDetailViewValidator;

class ReportAndDetailViewValidatorTest extends \TestCase {
  private $validator;
  private $request;

  protected function setUp() {
    $this->validator = $this->spy(ReportAndDetailViewValidator::class);
    $this->request = $this->mock('App\Http\Request');
  }

  public function testValidateReportName() {
    $this->request->shouldReceive('getApiAttribute')->with('reportName', '')->andReturn('');
    $this->invokeObjectMethod($this->validator, 'validateReportName', [$this->request]);

    $this->assertEquals(1, count($this->validator->getErrors()));
  }

  public function testValidateView() {
    $this->request->shouldReceive('getApiAttribute')->with('viewSchema')->andReturn('public');
    $this->request->shouldReceive('getApiAttribute')->with('viewName')->andReturn(null);
    $this->invokeObjectMethod($this->validator, 'validateView', [$this->request]);

    $this->assertEquals(1, count($this->validator->getErrors()));
  }

  public function testValidateUniqueId() {
    $this->request->shouldReceive('getApiAttribute')->with('uniqueId')->andReturn('');
    $this->invokeObjectMethod($this->validator, 'validateUniqueId', [$this->request]);

    $this->assertEquals(1, count($this->validator->getErrors()));
  }

  public function testValidateDetailViewName() {
    $this->request->shouldReceive('getApiAttribute')->with('detailViewName', '')->andReturn('');
    $this->invokeObjectMethod($this->validator, 'validateDetailViewName', [$this->request]);

    $this->assertEquals(1, count($this->validator->getErrors()));
  }

  public function testValidateReportRegionTemplate() {
    $this->request->shouldReceive('getApiAttribute')->with('reportRegionTemplate')->andReturn(null);
    $this->invokeObjectMethod($this->validator, 'validateReportRegionTemplate', [$this->request]);
    $this->assertEquals(1, count($this->validator->getErrors()));
  }

  public function testValidateDetailViewRegionTemplate() {
    $this->request->shouldReceive('getApiAttribute')->with('detailViewRegionTemplate')->andReturn(null);
    $this->invokeObjectMethod($this->validator, 'validateDetailViewRegionTemplate', [$this->request]);
    $this->assertEquals(1, count($this->validator->getErrors()));
  }

  public function testValidateReportSequence() {
    $this->request->shouldReceive('getApiAttribute')->with('reportRegionId')->andReturn(1);
    $this->request->shouldReceive('getApiAttribute')->with('reportPageId')->andReturn(1);
    $this->request->shouldReceive('getApiAttribute')->with('pageTemplateDisplayPointId')->andReturn(1);

    $this->request->shouldReceive('getApiAttribute')->with('reportSequence')->andReturn(-1);
    $this->invokeObjectMethod($this->validator, 'validateReportSequence', [$this->request]);
    $this->assertEquals(1, count($this->validator->getErrors()));

    $this->request->shouldReceive('getApiAttribute')->with('reportSequence')->andReturn(null);
    $this->invokeObjectMethod($this->validator, 'validateReportSequence', [$this->request]);
    $this->assertEquals(1, count($this->validator->getErrors()));
  }

  public function testValidateDetailViewSequence() {
    $this->request->shouldReceive('getApiAttribute')->with('detailViewRegionId')->andReturn(1);
    $this->request->shouldReceive('getApiAttribute')->with('detailViewPageId')->andReturn(1);
    $this->request->shouldReceive('getApiAttribute')->with('pageTemplateDisplayPointId')->andReturn(1);

    $this->request->shouldReceive('getApiAttribute')->with('detailViewSequence')->andReturn(-1);
    $this->invokeObjectMethod($this->validator, 'validateDetailViewSequence', [$this->request]);
    $this->assertEquals(1, count($this->validator->getErrors()));

    $this->request->shouldReceive('getApiAttribute')->with('detailViewSequence')->andReturn(null);
    $this->invokeObjectMethod($this->validator, 'validateDetailViewSequence', [$this->request]);
    $this->assertEquals(1, count($this->validator->getErrors()));
  }

  public function testValidateReportTemplate() {
    $this->request->shouldReceive('getApiAttribute')->with('reportTemplate')->andReturn(null);
    $this->invokeObjectMethod($this->validator, 'validateReportTemplate', [$this->request]);
    $this->assertEquals(1, count($this->validator->getErrors()));
  }

  public function testValidateDetailViewTemplate() {
    $this->request->shouldReceive('getApiAttribute')->with('detailViewTemplate')->andReturn(null);
    $this->invokeObjectMethod($this->validator, 'validateDetailViewTemplate', [$this->request]);
    $this->assertEquals(1, count($this->validator->getErrors()));
  }

  public function testValidateItemsPerPage() {
    $this->request->shouldReceive('getApiAttribute')->with('reportItemsPerPage')->andReturn(-1);
    $this->invokeObjectMethod($this->validator, 'validateItemsPerPage', [$this->request]);

    $this->assertEquals(1, count($this->validator->getErrors()));
  }

  public function testValidatePaginationQueryParameter() {
    $this->request->shouldReceive('getApiAttribute')->with('reportPaginationQueryParameter')->andReturn(null);
    $this->invokeObjectMethod($this->validator, 'validatePaginationQueryParameter', [$this->request]);
    $this->assertEquals(1, count($this->validator->getErrors()));

    $this->request->shouldReceive('getApiAttribute')->with('reportPaginationQueryParameter')->andReturn('page-1');
    $this->invokeObjectMethod($this->validator, 'validatePaginationQueryParameter', [$this->request]);
    $this->assertEquals(1, count($this->validator->getErrors()));

    $this->request->shouldReceive('getApiAttribute')->with('reportPaginationQueryParameter')->andReturn(-1);
    $this->invokeObjectMethod($this->validator, 'validatePaginationQueryParameter', [$this->request]);
    $this->assertEquals(1, count($this->validator->getErrors()));
  }

  public function testValidateDetailViewPageId() {
    $this->request->shouldReceive('getApiAttribute')->with('detailViewPageId')->andReturn('');
    $this->invokeObjectMethod($this->validator, 'validateDetailViewPageId', [$this->request]);
    $this->assertEquals(1, count($this->validator->getErrors()));
  }

  public function testValidateColumnsWithoutLink() {
    $columns = [
      array(
        'type' => 'detailview-column',
        'attributes' => array(
          'column' => 'column_example_1',
          'heading' => 'HeadingExample_1',
          'isTextEscaped' => true,
          'sequence' => 1,
          'type' => 'COLUMN'
        )
      ),
      array(
        'type' => 'detailview-column',
        'attributes' => array(
          'column' => 'column_example_1',
          'heading' => '',
          'isTextEscaped' => true,
          'sequence' => 1,
          'type' => 'COLUMN'
        )
      )
    ];

    $this->invokeObjectMethod($this->validator, 'validateColumns', [$columns, 'detailView']);
    $this->assertEquals(2, count($this->validator->getErrors()));
  }
}
