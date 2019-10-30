@isTest
public class PDFCreateControlerTests {

 	static testMethod void ShouldCreateSignature()
	{
		Enrollment_Form__c form = new Enrollment_Form__c(
			Digital_Signature__c = 'test'
		);

		insert form;

		PDFCreateController.updateSignature(form);

		List<Attachment> attachments = [
			select id from attachment where parentid =: form.id
		];

		System.assert(attachments.size() == 1);
	}

	static testMethod void ShouldDeleteSignature()
	{

		Enrollment_Form__c form = new Enrollment_Form__c(
			Digital_Signature__c = 'test'
		);

		insert form;

		PDFCreateController.updateSignature(form);
		PDFCreateController.updateSignature(form);

		List<Attachment> attachments = [
			select id from attachment where parentid =: form.id
		];

		System.assert(attachments.size() == 1);
	}

	static testMethod void ShouldReturnTrueForValidForm()
	{
		Enrollment_Form__c form = new Enrollment_Form__c(
			Printed_Signature__c = 'test',
			Title__c = 'test',
			Digital_Signature__c = 'test',
			Month__c = '2',
			Day__c = '3',
			Year__c = '2010'
		);

		boolean isValid = PDFCreateController.ValidateEnrollmentForm(form);

		System.assert(isValid);

	}
	static testMethod void ShouldReturnFalseForInvalidForm()
	{

		Enrollment_Form__c form = new Enrollment_Form__c(
			Title__c = 'test',
			Digital_Signature__c = 'test',
			Month__c = '2',
			Day__c = '3',
			Year__c = '2010'
		);

		boolean isValid = PDFCreateController.ValidateEnrollmentForm(form);

		System.assert(isValid == false);
	}
	static testMethod void ShouldReturnFalseForInvalidFormMissingPrintedSignature()
	{

		Enrollment_Form__c form = new Enrollment_Form__c(
			Title__c = 'test',
			Digital_Signature__c = 'test',
			Month__c = '2',
			Day__c = '3',
			Year__c = '2010'
		);

		boolean isValid = PDFCreateController.ValidateEnrollmentForm(form);

		System.assert(isValid == false);
	}

	static testMethod void ShouldReturnFalseForInvalidFormTitle()
	{

		Enrollment_Form__c form = new Enrollment_Form__c(
			Printed_Signature__c = 'test',
			Digital_Signature__c = 'test',
			Month__c = '2',
			Day__c = '3',
			Year__c = '2010'
		);

		boolean isValid = PDFCreateController.ValidateEnrollmentForm(form);

		System.assert(isValid == false);
	}

	static testMethod void ShouldReturnFalseForInvalidFormDigitalSignature()
	{

		Enrollment_Form__c form = new Enrollment_Form__c(
			Printed_Signature__c = 'test',
			Title__c = 'test',
			Month__c = '2',
			Day__c = '3',
			Year__c = '2010'
		);

		boolean isValid = PDFCreateController.ValidateEnrollmentForm(form);

		System.assert(isValid == false);
	}
	static testMethod void ShouldReturnFalseForInvalidFormMonth()
	{

		Enrollment_Form__c form = new Enrollment_Form__c(
			Printed_Signature__c = 'test',
			Title__c = 'test',
			Digital_Signature__c = 'test',
			Day__c = '3',
			Year__c = '2010'
		);

		boolean isValid = PDFCreateController.ValidateEnrollmentForm(form);

		System.assert(isValid == false);
	}

	static testMethod void ShouldReturnFalseForInvalidFormDay()
	{

		Enrollment_Form__c form = new Enrollment_Form__c(
			Printed_Signature__c = 'test',
			Title__c = 'test',
			Digital_Signature__c = 'test',
			Year__c = '2010',
			Month__c = '2'
		);

		boolean isValid = PDFCreateController.ValidateEnrollmentForm(form);

		System.assert(isValid == false);
	}

	static testMethod void ShouldReturnFalseForInvalidFormYear()
	{

		Enrollment_Form__c form = new Enrollment_Form__c(
			Printed_Signature__c = 'test',
			Title__c = 'test',
			Digital_Signature__c = 'test',
			Month__c = '2',
			Day__c = '3'
		);

		boolean isValid = PDFCreateController.ValidateEnrollmentForm(form);

		System.assert(isValid == false);
	}
	static testMethod void ShouldReturnNotNeededStatus()
	{
		string status = PDFCreateController.getEnrollmentFormStatus(
			new Enrollment_Form__c(
				Status__c = PDFCreateController.notNeededStatus));

		System.assert(status == PDFCreateController.notNeededStatus);
	}

	static testMethod void ShouldReturnInProgressStatus()
	{

		string status = PDFCreateController.getEnrollmentFormStatus(
			new Enrollment_Form__c(
				Status__c = PDFCreateController.submittedStatus));

		System.assert(status == PDFCreateController.inProgressStatus);
	}

}