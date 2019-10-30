global class FormStatusWrapperClass implements comparable{
    
    // This calss is used on the Form Status visual force page to implement a custom
    // sort order as well as show custom information for the page.
    
    public string formName		{get;set;}
    public string status		{get;set;}
    public string OwnerName		{get;set;}
    public Integer sortNum		{get;set;}
    
    public FormStatusWrapperClass(string f, string s, string o, integer i)
    {
        formName = f;
        status = s;
        ownerName = o;
        sortNum = i;
    }
    
    global Integer compareTo(object objToCompare)
    {
        FormStatusWrapperClass compareTo = (FormStatusWrapperClass) objToCompare;
        integer returnValue = 0;
        
        if(sortNum > compareTo.sortNum)
            returnValue = 1;
        else if(sortNum < compareTo.sortNum)
            returnValue = -1;
        
        return returnValue;
    }
}