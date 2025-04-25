// Listen for events from Lua
window.addEventListener('message', function (event) {
    if (event.data.action === 'openBlackMarket') {
        const items = event.data.items; // Get the items from the Lua event
        const itemList = document.getElementById('items');
        itemList.innerHTML = ''; // Clear any previous items

        // Dynamically populate the items
        items.forEach(item => {
            const listItem = document.createElement('li');
            listItem.innerHTML = `
                <span>${item.label} - $${item.price}</span>
                <button onclick="buyItem('${item.name}')">Buy</button>
            `;
            itemList.appendChild(listItem);
        });

        document.body.style.display = 'flex'; // Show the UI
    }
});

// Function to handle item purchase
function buyItem(itemName) {
    fetch(`https://${GetParentResourceName()}/buyItem`, {
        method: 'POST',
        body: JSON.stringify({ itemName })
    }).then(() => {
        console.log(`Purchased item: ${itemName}`);
    });
}

// Function to close the menu
function closeMenu() {
    fetch(`https://${GetParentResourceName()}/closeMenu`, { method: 'POST' });
    document.body.style.display = 'none'; // Hide the UI
}
