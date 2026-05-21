// API Configuration
const API_BASE_URL = 'http://localhost:8000';

// Helper functions
function getToken() {
    return localStorage.getItem('auth_token');
}

function setToken(token) {
    localStorage.setItem('auth_token', token);
}

function removeToken() {
    localStorage.removeItem('auth_token');
}

function isLoggedIn() {
    return !!getToken();
}

// Check authentication on page load (except login page)
function checkAuth() {
    const currentPage = window.location.pathname;
    const isLoginPage = currentPage.includes('index.html') || currentPage === '/';
    
    if (!isLoginPage && !isLoggedIn()) {
        window.location.href = 'index.html';
        return;
    }
    
    if (isLoginPage && isLoggedIn()) {
        window.location.href = 'profile.html';
        return;
    }
}

// Show message
function showMessage(elementId, message, isError = false) {
    const element = document.getElementById(elementId);
    element.textContent = message;
    element.style.display = 'block';
    
    setTimeout(() => {
        element.style.display = 'none';
    }, 3000);
}

// Login functionality
async function login(username, password) {
    try {
        const response = await fetch(`${API_BASE_URL}/auth/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ username, password })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            setToken(data.token);
            // Store both username and full_name for emergency signal
            localStorage.setItem('current_username', data.user.username);
            localStorage.setItem('current_fullname', data.user.full_name || data.user.username);
            return { success: true, data };
        } else {
            return { success: false, error: data.detail || 'Login failed' };
        }
    } catch (error) {
        console.error('Login error:', error);
        return { success: false, error: 'Network error. Please try again.' };
    }
}

// Logout functionality
async function logout() {
    const token = getToken();
    
    try {
        await fetch(`${API_BASE_URL}/auth/logout?token=${token}`, {
            method: 'POST'
        });
    } catch (error) {
        console.error('Logout error:', error);
    } finally {
        removeToken();
        window.location.href = 'index.html';
    }
}

// Get user profile
async function getProfile() {
    const token = getToken();
    
    try {
        const response = await fetch(`${API_BASE_URL}/user/profile?token=${token}`);
        
        if (response.ok) {
            return await response.json();
        } else {
            throw new Error('Failed to get profile');
        }
    } catch (error) {
        console.error('Get profile error:', error);
        throw error;
    }
}

// Update user profile
async function updateProfile(profileData) {
    const token = getToken();
    
    try {
        const response = await fetch(`${API_BASE_URL}/user/profile?token=${token}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(profileData)
        });
        
        const data = await response.json();
        
        if (response.ok) {
            return { success: true, data };
        } else {
            return { success: false, error: data.detail || 'Update failed' };
        }
    } catch (error) {
        console.error('Update profile error:', error);
        return { success: false, error: 'Network error. Please try again.' };
    }
}

// Get emergency contacts
async function getEmergencyContacts() {
    const token = getToken();
    
    try {
        const response = await fetch(`${API_BASE_URL}/user/emergency-contacts/?token=${token}`);
        
        if (response.ok) {
            return await response.json();
        } else {
            throw new Error('Failed to get contacts');
        }
    } catch (error) {
        console.error('Get contacts error:', error);
        throw error;
    }
}

// Update emergency contacts
async function updateEmergencyContacts(contacts) {
    const token = getToken();
    
    try {
        const response = await fetch(`${API_BASE_URL}/user/emergency-contacts/?token=${token}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ contacts })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            return { success: true, data };
        } else {
            return { success: false, error: data.detail || 'Update failed' };
        }
    } catch (error) {
        console.error('Update contacts error:', error);
        return { success: false, error: 'Network error. Please try again.' };
    }
}

// Initialize login page
function initLoginPage() {
    const loginForm = document.getElementById('loginForm');
    
    if (loginForm) {
        loginForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const username = document.getElementById('username').value;
            const password = document.getElementById('password').value;
            
            const result = await login(username, password);
            
            if (result.success) {
                window.location.href = 'profile.html';
            } else {
                showMessage('errorMessage', result.error, true);
            }
        });
    }
}

// Initialize profile page
async function initProfilePage() {
    const profileForm = document.getElementById('profileForm');
    
    if (!profileForm) return;
    
    // Load profile data
    try {
        const profile = await getProfile();
        
        document.getElementById('fullName').value = profile.full_name || '';
        document.getElementById('address').value = profile.address || '';
        document.getElementById('phone').value = profile.phone || '';
        document.getElementById('email').value = profile.email || '';
        document.getElementById('currentCity').value = profile.current_city || '';
        document.getElementById('currentCountry').value = profile.current_country || '';
        document.getElementById('hotelName').value = profile.hotel_name || '';
        
        // Handle form submission
        profileForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const profileData = {
                full_name: document.getElementById('fullName').value,
                address: document.getElementById('address').value,
                phone: document.getElementById('phone').value,
                email: document.getElementById('email').value,
                current_city: document.getElementById('currentCity').value,
                current_country: document.getElementById('currentCountry').value,
                hotel_name: document.getElementById('hotelName').value
            };
            
            const result = await updateProfile(profileData);
            
            if (result.success) {
                showMessage('successMessage', 'Profile updated successfully!');
            } else {
                showMessage('errorMessage', result.error, true);
            }
        });
    } catch (error) {
        showMessage('errorMessage', 'Failed to load profile', true);
    }
}

// Initialize contacts page
async function initContactsPage() {
    const contactsList = document.getElementById('contactsList');
    const contactsContainer = document.getElementById('contactsContainer');
    const contactsForm = document.getElementById('contactsForm');
    
    if (!contactsList || !contactsContainer || !contactsForm) return;
    
    // Load contacts
    try {
        const contacts = await getEmergencyContacts();
        
        // Display contacts list
        contactsList.innerHTML = contacts.map(contact => `
            <div class="contact-item">
                <span class="priority-badge">Priority ${contact.priority}</span>
                <h3>${contact.contact_name}</h3>
                <div class="contact-info">
                    <p><strong>Relationship:</strong> ${contact.relationship || 'N/A'}</p>
                    <p><strong>Phone:</strong> ${contact.phone || 'N/A'}</p>
                    <p><strong>WhatsApp:</strong> ${contact.whatsapp || 'N/A'}</p>
                </div>
            </div>
        `).join('');
        
        // Generate contact forms
        contactsContainer.innerHTML = contacts.map((contact, index) => `
            <div class="contact-form-item">
                <h3>Contact ${index + 1} (Priority ${contact.priority})</h3>
                <div class="form-group">
                    <label for="contact_${index}_name">Contact Name</label>
                    <input type="text" id="contact_${index}_name" value="${contact.contact_name}" required>
                </div>
                <div class="form-group">
                    <label for="contact_${index}_relationship">Relationship</label>
                    <input type="text" id="contact_${index}_relationship" value="${contact.relationship || ''}">
                </div>
                <div class="form-group">
                    <label for="contact_${index}_phone">Phone</label>
                    <input type="tel" id="contact_${index}_phone" value="${contact.phone || ''}">
                </div>
                <div class="form-group">
                    <label for="contact_${index}_whatsapp">WhatsApp</label>
                    <input type="tel" id="contact_${index}_whatsapp" value="${contact.whatsapp || ''}">
                </div>
            </div>
        `).join('');
        
        // Handle form submission
        contactsForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const updatedContacts = contacts.map((contact, index) => ({
                priority: contact.priority,
                contact_name: document.getElementById(`contact_${index}_name`).value,
                relationship: document.getElementById(`contact_${index}_relationship`).value,
                phone: document.getElementById(`contact_${index}_phone`).value,
                whatsapp: document.getElementById(`contact_${index}_whatsapp`).value
            }));
            
            const result = await updateEmergencyContacts(updatedContacts);
            
            if (result.success) {
                showMessage('successMessage', 'Emergency contacts updated successfully!');
                // Reload contacts display
                initContactsPage();
            } else {
                showMessage('errorMessage', result.error, true);
            }
        });
    } catch (error) {
        showMessage('errorMessage', 'Failed to load contacts', true);
    }
}

// Show snackbar notification
function showSnackbar(message, type = 'success') {
    const snackbar = document.getElementById('snackbar');
    if (!snackbar) return;
    
    snackbar.textContent = message;
    snackbar.className = `snackbar show ${type}`;
    
    setTimeout(() => {
        snackbar.className = snackbar.className.replace('show', '');
    }, 3000);
}

// Trigger emergency SOS
async function triggerEmergencySOS() {
    const token = getToken();
    if (!token) {
        showSnackbar('Please login first', 'error');
        return;
    }
    
    // Get current user info - try to get from localStorage first
    let userName = localStorage.getItem('current_username');
    
    // If not in localStorage, try to get from profile API
    if (!userName || userName === 'unknown') {
        try {
            const response = await fetch(`${API_BASE_URL}/user/profile?token=${token}`);
            if (response.ok) {
                const profile = await response.json();
                userName = profile.username || 'unknown';
                // Cache it for future use
                localStorage.setItem('current_username', userName);
            } else {
                console.error('Failed to fetch user profile:', response.statusText);
                // Try to get username from token by decoding it
                // Since tokens are session_{id}, we can't decode username from it directly
                // So we'll use a fallback
                userName = 'unknown';
                showSnackbar('Could not determine user info', 'error');
                return;
            }
        } catch (error) {
            console.error('Failed to fetch user profile:', error);
            showSnackbar('Network error. Please try again.', 'error');
            return;
        }
    }
    
    const payload = {
        type: "emergency",
        user_name: userName,
        signal: "SOS_BUTTON"
    };
    
    console.log('Sending emergency signal:', payload);
    
    try {
        const response = await fetch(`${API_BASE_URL}/emergency/webhook`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(payload)
        });
        
        const data = await response.json();
        
        if (response.ok && data.status === 'success') {
            showSnackbar('🚨 Emergency Triggered', 'success');
            console.log('Emergency signal sent successfully:', data);
        } else {
            showSnackbar('Failed to trigger emergency', 'error');
            console.error('Emergency trigger failed:', data);
        }
    } catch (error) {
        console.error('Emergency trigger error:', error);
        showSnackbar('Network error. Please try again.', 'error');
    }
}

// Initialize emergency button
function initEmergencyButton() {
    const emergencyBtn = document.getElementById('emergencyBtn');
    
    if (emergencyBtn) {
        emergencyBtn.addEventListener('click', async (e) => {
            e.preventDefault();
            
            // Confirm before triggering
            if (confirm('⚠️ This will send an emergency SOS signal. Continue?')) {
                await triggerEmergencySOS();
            }
        });
    }
}

// Initialize app
document.addEventListener('DOMContentLoaded', () => {
    checkAuth();
    initLoginPage();
    initProfilePage();
    initContactsPage();
    initEmergencyButton();
});
