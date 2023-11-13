{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire images older than ${expire_untagged_images_days} days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": ${expire_untagged_images_days}
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
