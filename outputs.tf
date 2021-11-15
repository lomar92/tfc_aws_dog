# What is my IP/DNS?

output "DogApp_IP" {
  value = "http://${aws_eip.DogApp.public_ip}"
}