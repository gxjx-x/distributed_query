"""
SSL certificate management for Aurora DSQL connections.

This module handles SSL certificate downloading and caching for secure
Aurora DSQL connections. The actual connection management is handled
by the pool.py module.
"""

import os
import urllib.request
import tempfile
import threading

# Global certificate cache
_root_ca_cert_path = None
_cert_lock = threading.Lock()

# Amazon Root CA certificate URL
AMAZON_ROOT_CA_URL = "https://www.amazontrust.com/repository/AmazonRootCA1.pem"


def get_amazon_root_ca_cert():
    """Download and cache the Amazon Root CA certificate"""
    global _root_ca_cert_path
    
    with _cert_lock:
        if _root_ca_cert_path and os.path.exists(_root_ca_cert_path):
            return _root_ca_cert_path
        
        try:
            # Download the certificate
            print("Downloading Amazon Root CA certificate...")
            with urllib.request.urlopen(AMAZON_ROOT_CA_URL) as response:
                cert_data = response.read()
            
            # Create a temporary file to store the certificate
            temp_fd, temp_path = tempfile.mkstemp(suffix='.pem', prefix='amazon_root_ca_')
            try:
                with os.fdopen(temp_fd, 'wb') as temp_file:
                    temp_file.write(cert_data)
                
                _root_ca_cert_path = temp_path
                print(f"Amazon Root CA certificate cached at: {_root_ca_cert_path}")
                return _root_ca_cert_path
                
            except Exception as e:
                # Clean up the temp file if there was an error
                try:
                    os.unlink(temp_path)
                except:
                    pass
                raise e
                
        except Exception as e:
            print(f"Failed to download Amazon Root CA certificate: {e}")
            # Fall back to system certificates
            return "system"
