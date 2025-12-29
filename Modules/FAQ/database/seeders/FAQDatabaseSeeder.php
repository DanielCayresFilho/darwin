<?php

namespace Modules\FAQ\database\seeders;

use Illuminate\Database\Seeder;

class FAQDatabaseSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run()
    {
        \DB::table('faqs')->delete();
        if (env('IS_DUMMY_DATA')) {

        \DB::table('faqs')->insert(array(
            0 =>
                array(
                    'id' => 1,
                    'question' => 'What is Metacare?',
                    'answer' => 'Metacare is an innovative therapy service platform. A psychological metaverse, i.e. a virtual space of online sessions and immersive reality, where you can find a trained professional and a safe place, free of judgement, available anywhere.',
                    'status' => 1,
                    'created_by' => 2,
                    'updated_by' => 2,
                    'deleted_by' => NULL,
                    'created_at' => '2024-12-19 06:43:30',
                    'updated_at' => '2024-12-19 06:43:30',
                    'deleted_at' => NULL,
                ),
            1 =>
                array(
                    'id' => 2,
                    'question' => 'How do I access therapy services using Metacare?',
                    'answer' => 'To access therapy services, simply create an account on Metacare, complete the questionnaire, and choose your preferred therapy mode - video conferencing or immersive virtual room. The system allows you to connect with qualified therapists and access your treatment pathway.',
                    'status' => 1,
                    'created_by' => 2,
                    'updated_by' => 2,
                    'deleted_by' => NULL,
                    'created_at' => '2024-12-19 06:44:16',
                    'updated_at' => '2024-12-19 06:44:16',
                    'deleted_at' => NULL,
                ),
            2 =>
                array(
                    'id' => 3,
                    'question' => 'What features does Metacare offer?',
                    'answer' => 'Metacare offers features such as immersive therapy rooms, online video conferencing therapy, self-care pathways, qualified therapist selection, custom avatars, appointment scheduling, and much more. It is designed to provide innovative psychological support with ease.',
                    'status' => 1,
                    'created_by' => 2,
                    'updated_by' => 2,
                    'deleted_by' => NULL,
                    'created_at' => '2024-12-19 06:44:36',
                    'updated_at' => '2024-12-19 06:44:36',
                    'deleted_at' => NULL,
                ),
            3 =>
                array(
                    'id' => 4,
                    'question' => 'Can I access therapy from anywhere with Metacare?',
                    'answer' => 'Yes, Metacare supports accessing therapy from anywhere. You only need an internet connection from a PC, tablet or telephone. For the full immersive experience, visors are additionally required.',
                    'status' => 1,
                    'created_by' => 2,
                    'updated_by' => 2,
                    'deleted_by' => NULL,
                    'created_at' => '2024-12-19 06:44:57',
                    'updated_at' => '2024-12-19 06:44:57',
                    'deleted_at' => NULL,
                ),
            4 =>
                array(
                    'id' => 5,
                    'question' => 'How can I manage appointments on Metacare?',
                    'answer' => 'To manage appointments, simply use the integrated appointment scheduler in your dashboard. You can schedule therapy sessions, manage your appointments, and access your treatment pathway through video conferencing or immersive virtual rooms.',
                    'status' => 1,
                    'created_by' => 2,
                    'updated_by' => 2,
                    'deleted_by' => NULL,
                    'created_at' => '2024-12-19 06:45:14',
                    'updated_at' => '2024-12-19 06:45:14',
                    'deleted_at' => NULL,
                ),
            5 =>
                array(
                    'id' => 6,
                    'question' => 'How does Metacare handle therapy sessions?',
                    'answer' => 'Metacare allows you to access therapy through video conferencing or immersive virtual rooms. You can interact with your therapist using custom avatars, providing a safe and judgment-free environment for your mental well-being.',
                    'status' => 1,
                    'created_by' => 2,
                    'updated_by' => 2,
                    'deleted_by' => NULL,
                    'created_at' => '2024-12-19 06:45:33',
                    'updated_at' => '2024-12-19 06:45:33',
                    'deleted_at' => NULL,
                ),
            6 =>
                array(
                    'id' => 7,
                    'question' => 'Is there a self-care option in Metacare?',
                    'answer' => 'Yes, Metacare includes self-care pathways where you can access virtual reality environments without the presence of a therapist. You can carry out self-care pathways for personal growth in your well-being.',
                    'status' => 1,
                    'created_by' => 2,
                    'updated_by' => 2,
                    'deleted_by' => NULL,
                    'created_at' => '2024-12-19 06:45:48',
                    'updated_at' => '2024-12-19 06:45:48',
                    'deleted_at' => NULL,
                ),
            7 =>
                array(
                    'id' => 8,
                    'question' => 'How do I customize my therapy experience on Metacare?',
                    'answer' => 'You can customize your therapy experience by choosing your preferred therapist, selecting therapy mode (video or immersive), customizing your avatar, and choosing virtual environments that suit your needs for a personalized experience.',
                    'status' => 1,
                    'created_by' => 2,
                    'updated_by' => 2,
                    'deleted_by' => NULL,
                    'created_at' => '2024-12-19 06:46:05',
                    'updated_at' => '2024-12-19 06:46:05',
                    'deleted_at' => NULL,
                ),
            8 =>
                array(
                    'id' => 9,
                    'question' => 'Can I access Metacare on mobile devices?',
                    'answer' => 'Yes, Metacare is fully accessible on mobile devices. You can access your therapy sessions, manage appointments, and use self-care pathways via your smartphone or tablet with an internet connection.',
                    'status' => 1,
                    'created_by' => 2,
                    'updated_by' => 2,
                    'deleted_by' => NULL,
                    'created_at' => '2024-12-19 06:46:21',
                    'updated_at' => '2024-12-19 06:46:21',
                    'deleted_at' => NULL,
                ),
            9 =>
                array(
                    'id' => 10,
                    'question' => 'Is Metacare mobile-friendly?',
                    'answer' => 'Yes, Metacare is fully mobile-responsive. You can access your therapy sessions, schedule appointments, and manage your mental well-being via your smartphones or tablets.',
                    'status' => 1,
                    'created_by' => 2,
                    'updated_by' => 2,
                    'deleted_by' => NULL,
                    'created_at' => '2024-12-19 06:46:40',
                    'updated_at' => '2024-12-19 06:46:40',
                    'deleted_at' => NULL,
                ),
            10 =>
                array(
                    'id' => 11,
                    'question' => 'Does Metacare offer session reminders?',
                    'answer' => 'Yes, Metacare can send automatic reminders about your upcoming therapy sessions, which can be configured to send via email or SMS to help you stay on track with your mental well-being journey.',
                    'status' => 1,
                    'created_by' => 2,
                    'updated_by' => 2,
                    'deleted_by' => NULL,
                    'created_at' => '2024-12-19 06:51:25',
                    'updated_at' => '2024-12-19 06:51:25',
                    'deleted_at' => NULL,
                ),
            11 =>
                array(
                    'id' => 12,
                    'question' => 'Can I choose different therapists on Metacare?',
                    'answer' => 'Yes, Metacare allows you to choose from qualified psychologists and psychotherapists with different specializations. You can evaluate and select the professional that best fits your needs and treatment requirements.',
                    'status' => 1,
                    'created_by' => 2,
                    'updated_by' => 2,
                    'deleted_by' => NULL,
                    'created_at' => '2024-12-19 06:51:47',
                    'updated_at' => '2024-12-19 06:51:47',
                    'deleted_at' => NULL,
                ),
            12 =>
                array(
                    'id' => 13,
                    'question' => 'Is there an option to track my therapy progress in Metacare?',
                    'answer' => 'Yes, Metacare lets you track your therapy progress, including past sessions, treatment pathways, and your journey towards improved mental well-being and emotional health.',
                    'status' => 1,
                    'created_by' => 2,
                    'updated_by' => 2,
                    'deleted_by' => NULL,
                    'created_at' => '2024-12-19 06:52:05',
                    'updated_at' => '2024-12-19 06:52:05',
                    'deleted_at' => NULL,
                ),
            13 =>
                array(
                    'id' => 14,
                    'question' => 'How do I set up patient billing?',
                    'answer' => 'You can set up patient billing by navigating to the billing section in your admin dashboard. You can create and send invoices, accept payments, and manage billing details.',
                    'status' => 1,
                    'created_by' => 2,
                    'updated_by' => 2,
                    'deleted_by' => NULL,
                    'created_at' => '2024-12-19 06:52:21',
                    'updated_at' => '2024-12-19 06:52:21',
                    'deleted_at' => NULL,
                ),
            14 =>
                array(
                    'id' => 15,
                    'question' => 'Can I delete patient records?',
                    'answer' => 'Yes, you can delete patient records from the system, though we recommend keeping patient history for medical reference. Deletion is irreversible.',
                    'status' => 1,
                    'created_by' => 2,
                    'updated_by' => 2,
                    'deleted_by' => NULL,
                    'created_at' => '2024-12-19 06:52:38',
                    'updated_at' => '2024-12-19 06:52:38',
                    'deleted_at' => NULL,
                ),
            15 =>
                array(
                    'id' => 16,
                    'question' => 'Can I provide access to staff members?',
                    'answer' => 'Yes, you can provide limited access to other staff members. Each staff member can be assigned specific roles and permissions, ensuring they can only access the parts of the system they need.',
                    'status' => 1,
                    'created_by' => 2,
                    'updated_by' => 2,
                    'deleted_by' => NULL,
                    'created_at' => '2024-12-19 06:52:56',
                    'updated_at' => '2024-12-19 06:52:56',
                    'deleted_at' => NULL,
                ),
        ));
    }
    }
}
