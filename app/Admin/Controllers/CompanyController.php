<?php

namespace App\Admin\Controllers;

use App\Models\Company;
use Encore\Admin\Controllers\AdminController;
use Encore\Admin\Form;
use Encore\Admin\Grid;
use Encore\Admin\Show;

class CompanyController extends AdminController
{
    /**
     * Title for current resource.
     *
     * @var string
     */
    protected $title = 'Company';

    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        $grid = new Grid(new Company());

        $grid->column('company_id', __('Company id'));
        $grid->column('owner_user_id', __('Owner user id'));
        $grid->column('name', __('Name'));
        $grid->column('subdomain', __('Subdomain'));
        $grid->column('email', __('Email'));
        $grid->column('phone', __('Phone'));
        $grid->column('country', __('Country'));
        $grid->column('address', __('Address'));
        $grid->column('website', __('Website'));
        $grid->column('logo_url', __('Logo url'));
        $grid->column('description', __('Description'));
        $grid->column('license_expiry_date', __('License expiry date'));


        return $grid;
    }

    /**
     * Make a show builder.
     *
     * @param mixed $id
     * @return Show
     */
    protected function detail($id)
    {
        $show = new Show(Company::findOrFail($id));

        $show->field('company_id', __('Company id'));
        $show->field('owner_user_id', __('Owner user id'));
        $show->field('name', __('Name'));
        $show->field('subdomain', __('Subdomain'));
        $show->field('email', __('Email'));
        $show->field('phone', __('Phone'));
        $show->field('country', __('Country'));
        $show->field('address', __('Address'));
        $show->field('website', __('Website'));
        $show->field('logo_url', __('Logo url'));
        $show->field('description', __('Description'));
        $show->field('license_expiry_date', __('License expiry date'));
        $show->field('payment_status', __('Payment status'));
        $show->field('status', __('Status'));
        $show->field('created_at', __('Created at'));
        $show->field('updated_at', __('Updated at'));
        $show->field('deleted_at', __('Deleted at'));

        return $show;
    }

    /**
     * Make a form builder.
     *
     * @return Form
     */
    protected function form()
    {
        $form = new Form(new Company());

        $form->number('company_id', __('Company id'));
        $form->text('owner_user_id', __('Owner user id'));
        $form->textarea('name', __('Name'));
        $form->textarea('subdomain', __('Subdomain'));
        $form->textarea('email', __('Email'));
        $form->textarea('phone', __('Phone'));
        $form->textarea('country', __('Country'));
        $form->textarea('address', __('Address'));
        $form->textarea('website', __('Website'));
        $form->textarea('logo_url', __('Logo url'));
        $form->textarea('description', __('Description'));
        $form->date('license_expiry_date', __('License expiry date'))->default(date('Y-m-d'));
        $form->text('payment_status', __('Payment status'));
        $form->text('status', __('Status'))->default('active');

        return $form;
    }
}
