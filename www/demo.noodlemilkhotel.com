server {
    listen 80;
    server_name demo.noodlemilkhotel.com;

    location / {
        root /var/www/demo.noodlemilkhotel.com;
        expires 30d;
    }
}
