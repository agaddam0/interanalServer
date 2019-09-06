Public class AccountHandler{

  Public static account insertNewAccount(string names){
       
          
          //acc.phone='9845652556';
          try{
          account acc=new account();
          acc.name=names;
          insert acc;
          return acc;
          }
          catch (DmlException e) {

    System.debug('A DML exception has occurred: ' +

                e.getMessage());
                return null;

}

       
  
  }
}