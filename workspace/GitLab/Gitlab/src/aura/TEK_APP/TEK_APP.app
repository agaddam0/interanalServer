<aura:application controller='Tek_Poc1' access='global'>
    <aura:attribute name='Account' type='Account[]'></aura:attribute>
    <aura:handler name='init' value='{!this}'  action='{!c.doInit}'></aura:handler>
    <table class="slds-table slds-table_cell-buffer slds-table_bordered slds-table_col-bordered">
       <thead>
            <tr class="slds-line-height_reset">
            <th class="" scope="col">
            <div class="slds-truncate" title="Account Name">Account Name</div>
            </th>
            <th class="" scope="col">
            <div class="slds-truncate" title="Type">Type</div>
            </th>
            </tr>
        </thead>
        <tbody>
           <aura:iteration var='acc' items='{!v.Account}'>
              <tr class="slds-hint-parent">
               <td data-label="Account Name">
        <div class="slds-truncate" title="Name">{!acc.Name}</div>
      </td>
         <td data-label="Account Type">
        <div class="slds-truncate" title="Type">{!acc.Type}</div>
      </td>

                  </tr>
            </aura:iteration>
        </tbody>
    </table>
</aura:application>