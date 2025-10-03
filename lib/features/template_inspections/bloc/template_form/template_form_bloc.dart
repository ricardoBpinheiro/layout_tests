// inspections/bloc/template_form/template_form_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/inspection_template_repository.dart';
import '../../models/inspection_template.dart';
import '../../models/inspection_step.dart';
import '../../models/inspection_section.dart';
import 'template_form_event.dart';
import 'template_form_state.dart';

class TemplateFormBloc extends Bloc<TemplateFormEvent, TemplateFormState> {
  final InspectionTemplateRepository _repo;
  TemplateFormBloc({required InspectionTemplateRepository repository})
    : _repo = repository,
      super(const TemplateFormState()) {
    on<TemplateFormStarted>(_onStarted);
    on<TemplateTitleChanged>(_onTitleChanged);
    on<TemplateDescriptionChanged>(_onDescriptionChanged);
    on<StepAdded>(_onStepAdded);
    on<StepRemoved>(_onStepRemoved);
    on<SectionAdded>(_onSectionAdded);
    on<SectionRemoved>(_onSectionRemoved);
    on<FieldAdded>(_onFieldAdded);
    on<FieldUpdated>(_onFieldUpdated);
    on<FieldRemoved>(_onFieldRemoved);
    on<RuleAdded>(_onRuleAdded);
    on<RuleRemoved>(_onRuleRemoved);
    on<TemplateSaved>(_onSaved);
  }

  Future<void> _onStarted(
    TemplateFormStarted event,
    Emitter<TemplateFormState> emit,
  ) async {
    emit(state.copyWith(status: TemplateFormStatus.loading));
    try {
      InspectionTemplate template;
      if (event.templateId != null) {
        template = await _repo.getById(event.templateId!);
      } else {
        // template = InspectionTemplate.empty();
      }
      // emit(
      //   state.copyWith(status: TemplateFormStatus.editing, template: template),
      // );
    } catch (e) {
      emit(
        state.copyWith(
          status: TemplateFormStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onTitleChanged(
    TemplateTitleChanged e,
    Emitter<TemplateFormState> emit,
  ) {
    final t = state.template!;
    emit(state.copyWith(template: t.copyWith(description: e.title)));
  }

  void _onDescriptionChanged(
    TemplateDescriptionChanged e,
    Emitter<TemplateFormState> emit,
  ) {
    final t = state.template!;
    emit(state.copyWith(template: t.copyWith(description: e.description)));
  }

  void _onStepAdded(StepAdded e, Emitter<TemplateFormState> emit) {
    final t = state.template!;
    // final steps = [...t.steps, InspectionStep.empty()];
    // emit(state.copyWith(template: t.copyWith(steps: steps)));
  }

  void _onStepRemoved(StepRemoved e, Emitter<TemplateFormState> emit) {
    final t = state.template!;
    final steps = [...t.steps]..removeAt(e.index);
    emit(state.copyWith(template: t.copyWith(steps: steps)));
  }

  void _onSectionAdded(SectionAdded e, Emitter<TemplateFormState> emit) {
    final t = state.template!;
    final steps = [...t.steps];
    final step = steps[e.stepIndex];
    // final sections = [...step.sections, InspectionSection.empty()];
    // steps[e.stepIndex] = step.copyWith(sections: sections);
    // emit(state.copyWith(template: t.copyWith(steps: steps)));
  }

  void _onSectionRemoved(SectionRemoved e, Emitter<TemplateFormState> emit) {
    final t = state.template!;
    final steps = [...t.steps];
    final step = steps[e.stepIndex];
    // final sections = [...step.sections]..removeAt(e.sectionIndex);
    // steps[e.stepIndex] = step.copyWith(sections: sections);
    // emit(state.copyWith(template: t.copyWith(steps: steps)));
  }

  void _onFieldAdded(FieldAdded e, Emitter<TemplateFormState> emit) {
    final t = state.template!;
    final steps = [...t.steps];
    final step = steps[e.stepIndex];
    // final sections = [...step.sections];
    // final section = sections[e.sectionIndex];
    // final fields = [...section.fields, e.field];
    // sections[e.sectionIndex] = section.copyWith(fields: fields);
    // steps[e.stepIndex] = step.copyWith(sections: sections);
    // emit(state.copyWith(template: t.copyWith(steps: steps)));
  }

  void _onFieldUpdated(FieldUpdated e, Emitter<TemplateFormState> emit) {
    final t = state.template!;
    final steps = [...t.steps];
    final step = steps[e.stepIndex];
    // final sections = [...step.sections];
    // final section = sections[e.sectionIndex];
    // final fields = [...section.fields];
    // fields[e.fieldIndex] = e.field;
    // sections[e.sectionIndex] = section.copyWith(fields: fields);
    // steps[e.stepIndex] = step.copyWith(sections: sections);
    // emit(state.copyWith(template: t.copyWith(steps: steps)));
  }

  void _onFieldRemoved(FieldRemoved e, Emitter<TemplateFormState> emit) {
    final t = state.template!;
    final steps = [...t.steps];
    final step = steps[e.stepIndex];
    // final sections = [...step.sections];
    // final section = sections[e.sectionIndex];
    // final fields = [...section.fields]..removeAt(e.fieldIndex);
    // sections[e.sectionIndex] = section.copyWith(fields: fields);
    // steps[e.stepIndex] = step.copyWith(sections: sections);
    // emit(state.copyWith(template: t.copyWith(steps: steps)));
  }

  void _onRuleAdded(RuleAdded e, Emitter<TemplateFormState> emit) {
    final t = state.template!;
    final steps = [...t.steps];
    final step = steps[e.stepIndex];
    // final sections = [...step.sections];
    // final section = sections[e.sectionIndex];
    // final fields = [...section.fields];
    // final field = fields[e.fieldIndex];
    // final rules = [...field.rules, e.rule];
    // fields[e.fieldIndex] = field.copyWith(rules: rules);
    // sections[e.sectionIndex] = section.copyWith(fields: fields);
    // steps[e.stepIndex] = step.copyWith(sections: sections);
    // emit(state.copyWith(template: t.copyWith(steps: steps)));
  }

  void _onRuleRemoved(RuleRemoved e, Emitter<TemplateFormState> emit) {
    final t = state.template!;
    final steps = [...t.steps];
    final step = steps[e.stepIndex];
    // final sections = [...step.sections];
    // final section = sections[e.sectionIndex];
    // final fields = [...section.fields];
    // final field = fields[e.fieldIndex];
    // final rules = [...field.rules]..removeAt(e.ruleIndex);
    // fields[e.fieldIndex] = field.copyWith(rules: rules);
    // sections[e.sectionIndex] = section.copyWith(fields: fields);
    // steps[e.stepIndex] = step.copyWith(sections: sections);
    // emit(state.copyWith(template: t.copyWith(steps: steps)));
  }

  Future<void> _onSaved(
    TemplateSaved e,
    Emitter<TemplateFormState> emit,
  ) async {
    final t = state.template!;
    emit(state.copyWith(status: TemplateFormStatus.saving));
    try {
      final saved = t.id == null || t.id!.isEmpty
          ? await _repo.create(t)
          : await _repo.update(t);
      emit(state.copyWith(status: TemplateFormStatus.success, template: saved));
    } catch (e) {
      emit(
        state.copyWith(
          status: TemplateFormStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
