# AWS-Wordpress

La mia soluzione cerca di soddisfare i seguenti requisiti:  
• è affidabile  
• è scalabile orizzontalmente  
• il suo deploy è automatizzato tramite Terraform  
• è hostato su AWS  

## Componenti

IAM: Per la gestione delle policy e dei role richiesti dal cluster  
VPC: Tre tipologie di subnet (private, pubblice e database) divise su due AZ  
ALB: L'interfaccia pubblica per esporre il sito su internet  
RDS: L'istanza del database  
EFS: File Storage per salvare dati persistenti di Wordpress  
ECS: Servizio cluster in modalità Fargate per il deploy dell'applicazione  
CloudWatch: Per il monitoring  
  
Nella repository è presente il diagramma dell'infrastruttura  
(https://github.com/SalvatoreCaiazza/AWS-Wordpress/blob/main/Infrastruttura.png?raw=true)
