import 'package:stage/features/notifications/models/notification_type.dart';

class NotificationRepository {
  List <NotificationItem > getNotifications() {
    return [
      NotificationItem(
          title: "Rappel d’entretien",
          message: "Le véhicule Renault Kangoo (TN-123-456) est dû pour un entretien aujourd’hui (vidange moteur).",
          time: 'il y a 5 minutes',
          type:NotificationType.entretien,
        isRead: true,
      ),
      NotificationItem(
        title: "Rappel hebdomadaire de vérification",
        message: "N’oubliez pas de vérifier les niveaux (huile, eau, frein) des véhicules affectés.",
        time: 'il y a 2 heures',
        type:NotificationType.rappel,
        isRead: true,
      ),
      NotificationItem(
        title: "Dépassement de kilométrage",
        message: "Le véhicule Toyota Hilux a dépassé le seuil de 10 000 km sans entretien.",
        time: 'il y a 3 heures',
        type:NotificationType.alerte,
        isRead: true,
      ),
      NotificationItem(
        title: "Suivi post-entretien",
        message: "L’entretien du véhicule Opel Combo a été effectué. Prochaine vérification dans 3 mois.",
        time: 'il y a 2 jours',
        type:NotificationType.suivi,
        isRead: true,
      ),
    ];
  }
}