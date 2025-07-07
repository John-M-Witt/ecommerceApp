/* 
Required triggers

- carts: 
    New cart created => 
        cart_status UPDATE to 'active'
        cart_created date INSERT now() 
    
    Cart cancelled =>
        cart status UPDATE to cancelled 
        INSERT cart_cancel_date now()
        
    Order submitted =>
        UPDATE cart status to 'ordered', 
        INSERT ordered_items into ordered carts_items, 
        DELETE ordered items from carts_items

- orders
    Add order_cancelled_date after order_status UPDATE to 'cancelled'
    calculate total_order_sales after cart_status UPDATE to 'ordered'
    



*/
