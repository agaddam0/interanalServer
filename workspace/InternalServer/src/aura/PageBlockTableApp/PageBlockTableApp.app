<aura:application controller="ContactController" access="GLOBAL" >
    
    <aura:attribute name="contacts" type="Contact[]" access="private"/>
    <aura:handler name="init" action="{!c.doInit}" value="{!this}" />
     <table class="slds-table slds-table_cell-buffer slds-table_bordered slds-table_col-bordered">
            <thead > 
              
                    <tr class="slds-text-title--caps">
                      <th scope="col">
                        <div class="slds-truncate" title=" Name"> Name</div>
                      </th>
                     
                      <th scope="col">
                        <div class="slds-truncate" title="Amount">Phone</div>
                      </th>
                      <th scope="col">
                        <div class="slds-truncate" title="Date">Email</div>
                      </th>
                     
                      <th scope="col">
                        <div class="slds-truncate" title="Client">Client Name</div>
                      </th>
                       <th scope="col">
                        <div class="slds-truncate" title="Reimbursed?">Birthdate</div>
                      </th>
                    </tr>
              </thead>
            <tbody>
    <aura:iteration var="contacts" items="{!v.contacts}">
                <tr>
                    <td><a href="#"> {!contacts.Name}</a></td>
                   <td> {!contacts.phone}</td>
                   <td> {!contacts.Email}</td>
                   <td> {!contacts.Account.Name}</td>
                   <td> {!contacts.Birthdate}</td>
                </tr>
            </aura:iteration> 
                  </tbody>     
        </table>
</aura:application>