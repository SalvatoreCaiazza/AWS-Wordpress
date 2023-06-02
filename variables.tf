#variabili VPC
variable "name" {
  type        = string
  description = "nome VPC"
}

variable "cidr" {
  type        = string
  description = "cidr block assegnato VPC"
}

variable "single_nat_gateway" {
  type        = bool
  description = "Abilita/disabilita single nat gateway"
}


#variabili VPC-subnets
variable "private_subnets" {
  type        = list(string)
  description = "Le subnets private assegnate"
}

variable "public_subnets" {
  type        = list(string)
  description = "Pool di subnets pubbliche assegnate"
}

variable "database_subnets" {
  type        = list(string)
  description = "Pool di subnets per i servizi di DB"
}

#region
variable "region" {
  type        = string
  description = "region scelta"
}




#variabili RDS-DB
variable "allocated_storage" {
  type        = number
  description = "Dimensione disco dell'istanza RDS"
}

variable "family" {
  type        = string
  description = "Family per l'istanza RDS"
}

variable "engine" {
  type        = string
  description = "Il Db-engine scelto per l'istanza"
}

variable "engine_version" {
  type        = string
  description = "versione engine"
}

variable "instance_class" {
  type        = string
  description = "tipo di istanza AWS scelta"
}

variable "db_name" {
  type        = string
  description = "nome del database"
}

variable "username" {
  type        = string
  description = "campo username del DB"
}

variable "db_port" {
  type        = string
  description = "Numero porta del database"
}

variable "major_engine_version" {
  type        = string
  description = "Major Engine Version"
}

variable "snapshot" {
  type        = bool
  description = "skip final snapshot"
}

#ECS
variable "container_image" {
  type        = string
  description = "Immagine usato"
}