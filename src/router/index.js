import { createRouter, createWebHistory } from 'vue-router';
import HomeView from '../views/HomeView.vue';
import LoginAdminView from '../views/LoginAdminView.vue';
import LoginRespondenteView from '../views/LoginRespondenteView.vue';
import AdminView from '../views/AdminView.vue';
import DashboardView from '../views/DashboardView.vue';
import FormularioView from '../views/FormularioView.vue';
import PreferenciasView from '../views/PreferenciasView.vue';
import ConclusaoView from '../views/ConclusaoView.vue';
import DebugView from '../views/DebugView.vue';

const routes = [
    {
        path: '/',
        name: 'Home',
        component: HomeView
    },
    {
        path: '/login-admin',
        name: 'LoginAdmin',
        component: LoginAdminView
    },
    {
        path: '/login-respondente',
        name: 'LoginRespondente',
        component: LoginRespondenteView
    },
    {
        path: '/admin',
        name: 'Admin',
        component: AdminView
    },
    {
        path: '/participante',
        name: 'Participante',
        component: DashboardView
    },
    {
        path: '/dashboard',
        redirect: '/participante'
    },
    {
        path: '/formulario',
        name: 'Formulario',
        component: FormularioView
    },
    {
        path: '/preferencias',
        name: 'Preferencias',
        component: PreferenciasView
    },
    {
        path: '/conclusao',
        name: 'Conclusao',
        component: ConclusaoView
    },
    {
        path: '/debug',
        name: 'Debug',
        component: DebugView
    }
];

const router = createRouter({
    history: createWebHistory(),
    routes
});

export default router;
